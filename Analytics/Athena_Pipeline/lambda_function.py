import os
import json
import boto3
import pgpy
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from botocore.exceptions import ClientError

# Initialize AWS clients with error handling
try:
    secrets_client = boto3.client('secretsmanager')
    ses_client = boto3.client('ses')
    s3_client = boto3.client('s3')
    glue_client = boto3.client('glue')
except Exception as e:
    print(f"Failed to initialize AWS clients: {str(e)}")
    raise

# Environment Variables with validation
try:
    REQUIRED_ENV_VARS = {
        'PGP_KEY_SECRET': os.environ['PGP_KEY_SECRET'],
        'PGP_PASSPHRASE_SECRET': os.environ['PGP_PASSPHRASE_SECRET'],
        'EMAIL_SENDER': os.environ['EMAIL_SENDER'],
        'EMAIL_RECIPIENT': os.environ['EMAIL_RECIPIENT'],
        'GLUE_CRAWLER_NAME': os.environ['GLUE_CRAWLER_NAME']
    }
except KeyError as e:
    raise ValueError(f"Missing required environment variable: {str(e)}")

def lambda_handler(event, context):
    try:
        print(f"Full event received: {json.dumps(event, indent=2)}")
        
        # Extract bucket and key with flexible event structure handling
        file_location = event.get('input', {}).get('fileLocation') or event.get('fileLocation')
        if not file_location:
            raise ValueError("Event missing fileLocation information")
            
        try:
            bucket = file_location['bucket']
            key = file_location['key']
        except KeyError as e:
            raise ValueError(f"Missing required field in fileLocation: {str(e)}")
        
        file_name = os.path.basename(key)
        print(f"Processing file: {file_name} from bucket: {bucket}")

        # Download encrypted file from S3
        try:
            encrypted_obj = s3_client.get_object(Bucket=bucket, Key=key)
            encrypted_data = encrypted_obj['Body'].read()
        except ClientError as e:
            raise Exception(f"Failed to download file from S3: {str(e)}")

        # Fetch secrets with error handling
        try:
            private_key_data = secrets_client.get_secret_value(
                SecretId=REQUIRED_ENV_VARS['PGP_KEY_SECRET']
            )['SecretString']
            passphrase = secrets_client.get_secret_value(
                SecretId=REQUIRED_ENV_VARS['PGP_PASSPHRASE_SECRET']
            )['SecretString']
        except ClientError as e:
            raise Exception(f"Failed to retrieve secrets: {str(e)}")

        # PGP operations with validation
        try:
            private_key, _ = pgpy.PGPKey.from_blob(private_key_data)
            if not private_key.unlock(passphrase):
                raise ValueError("Failed to unlock PGP key - incorrect passphrase?")
                
            encrypted_message = pgpy.PGPMessage.from_blob(encrypted_data)
            decrypted = private_key.decrypt(encrypted_message)
            decrypted_content = str(decrypted.message)
        except Exception as e:
            raise Exception(f"PGP decryption failed: {str(e)}")

        print("Decrypted content preview (first 200 chars):")
        print(decrypted_content[:200])

        # Validation (consider making this more robust)
        if "EXPECTED_CONTENT" not in decrypted_content:
            raise ValueError("File validation failed - expected content not found")

        # Upload decrypted content
        decrypted_key = key.replace('uploads/', 'decrypted/').replace('.pgp', '')
        try:
            s3_client.put_object(
                Bucket=bucket,
                Key=decrypted_key,
                Body=decrypted_content.encode('utf-8'),
                ServerSideEncryption='AES256'  # Enable encryption
            )
            print(f"Successfully uploaded decrypted file to s3://{bucket}/{decrypted_key}")
        except ClientError as e:
            raise Exception(f"Failed to upload decrypted file: {str(e)}")

        # Start Glue Crawler
        start_glue_crawler()

        # Send confirmation email
        send_confirmation_email(file_name)

        return {
            'statusCode': 200,
            'body': f"Successfully processed {file_name}"
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        send_error_notification(str(e), file_name if 'file_name' in locals() else "unknown")
        raise

def send_confirmation_email(file_name):
    subject = "✅ File Successfully Processed"
    body = f"""The file {file_name} was processed successfully.
    
    - Decrypted content validated
    - Stored in S3 decrypted folder
    - Glue crawler triggered
    """
    
    send_email(subject, body)

def send_error_notification(error_message, file_name):
    subject = "❌ File Processing Failed"
    body = f"""Processing failed for {file_name}.
    
    Error: {error_message}
    
    Please check CloudWatch logs for details.
    """
    
    send_email(subject, body)

def send_email(subject, body):
    msg = MIMEMultipart()
    msg['From'] = REQUIRED_ENV_VARS['EMAIL_SENDER']
    msg['To'] = REQUIRED_ENV_VARS['EMAIL_RECIPIENT']
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))
    
    try:
        response = ses_client.send_raw_email(
            Source=REQUIRED_ENV_VARS['EMAIL_SENDER'],
            Destinations=[REQUIRED_ENV_VARS['EMAIL_RECIPIENT']],
            RawMessage={'Data': msg.as_string()}
        )
        print(f"Email sent: {response['MessageId']}")
    except ClientError as e:
        print(f"Failed to send email: {str(e)}")
        # Don't raise - email failure shouldn't fail the whole operation

def start_glue_crawler():
    try:
        response = glue_client.start_crawler(Name=REQUIRED_ENV_VARS['GLUE_CRAWLER_NAME'])
        print(f"Started Glue crawler: {response}")
    except ClientError as e:
        print(f"Failed to start Glue crawler: {str(e)}")
        # Don't raise - crawler failure shouldn't fail the whole operation