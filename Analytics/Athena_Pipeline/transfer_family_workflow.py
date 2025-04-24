import os
import boto3
import pgpy
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Initialize AWS clients
secrets_client = boto3.client('secretsmanager')
ses_client = boto3.client('ses')

# Load environment variables
PGP_KEY_SECRET = os.environ['PGP_KEY_SECRET']
PGP_PASSPHRASE_SECRET = os.environ['PGP_PASSPHRASE_SECRET']
EMAIL_SENDER = os.environ['EMAIL_SENDER']
EMAIL_RECIPIENT = os.environ['EMAIL_RECIPIENT']

def lambda_handler(event, context):
    # Extract SFTP upload event details
    file_name = event['detail']['requestParameters']['fileName']
    encrypted_data = event['detail']['requestParameters']['fileData']

    # Fetch the PGP private key and passphrase from Secrets Manager
    private_key_data = secrets_client.get_secret_value(SecretId=PGP_KEY_SECRET)['SecretString']
    passphrase = secrets_client.get_secret_value(SecretId=PGP_PASSPHRASE_SECRET)['SecretString']

    # Load and unlock the PGP private key
    private_key, _ = pgpy.PGPKey.from_blob(private_key_data)
    private_key.unlock(passphrase)

    # Decrypt the file
    encrypted_message = pgpy.PGPMessage.from_blob(encrypted_data)
    decrypted = private_key.decrypt(encrypted_message)
    decrypted_content = str(decrypted.message)

    # Perform validation
    if "EXPECTED_CONTENT" in decrypted_content:
        print("File validated successfully.")
        send_confirmation_email(file_name)
    else:
        print("Validation failed: File content not as expected.")
        raise Exception("Validation failed")

def send_confirmation_email(file_name):
    """Send an email notification via SES."""
    subject = "File Successfully Received and Decrypted"
    body = f"The file {file_name} was successfully received, decrypted, and validated."

    # Create email
    msg = MIMEMultipart()
    msg['From'] = EMAIL_SENDER
    msg['To'] = EMAIL_RECIPIENT
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    # Send email via SES
    try:
        response = ses_client.send_raw_email(
            Source=EMAIL_SENDER,
            Destinations=[EMAIL_RECIPIENT],
            RawMessage={'Data': msg.as_string()}
        )
        print(f"Email sent: {response}")
    except Exception as e:
        print(f"Failed to send email: {str(e)}")
        raise e
