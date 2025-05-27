## Creating IAM POLICY AND ROLE

$ aws iam create-policy --policy-name Lambda-Policy --policy-document file://lambda_policy.json --tags Key=Name,Value=DEVAS
 aws iam create-policy --policy-name API_GATEWAY --policy-document fileb://api_gateway_policy.json

aws iam create-role --role-name Lambda-Role --assume-role-policy-document file://trust_policy.json

## Policy Attachment to role

>aws iam attach-role-policy --role-name Lambda-Role --policy-arn $(aws iam list-policies --scope All --query "Policies[?PolicyName=='Lambda-Policy'].Arn" --output text)

## Verify the Policy is Attached

aws iam list-attached-role-policies --role-name Lambda-Role

## Create a Lambda Function

aws lambda create-function \
  --function-name DATESTFUN \
  --runtime python3.8 \
  --role $(aws iam list-roles --query "Roles[?RoleName=='Lambda-Role'].Arn" --output text) \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip


## Get the hash value of the Latest version

aws lambda get-function \
  --function-name DATESTFUN \
  --query 'Configuration.[Version,CodeSha256]' \
  --output table
## List lambda version 

aws lambda list-versions-by-function --function-name DATESTFUN

## Publish a version

 aws lambda publish-version --function-name DATESTFUN --code-sha256 "$(aws lambda get-function --function-name DATESTFUN --query 'Configuration.CodeSha256' --output text)"

When you specify --code-sha256, AWS Lambda checks whether the base64-encoded SHA-256 hash of the $LATEST function code matches the value you provide. This ensures:

You're publishing a version of the exact code you intended.

Adds an extra layer of security against accidental or malicious changes.

$LATEST  --  	The most recent update to your function — even if it’s not published as a version.

Published versions (1, 2, 3, …`)  -- 	Snapshots of your function's code + config at the time of publishing via aws lambda publish-version.

✅ What happened in this case:
You created the function → $LATEST and version 1 appeared (first publish-version).

Then you ran publish-version again without changing anything.

AWS Lambda noticed no changes, so it didn't create a new version — you still see only 1.


## Create Lambda Aiases

 aws lambda create-alias --function-name DATESTFUN --name prod --function-version 1

 ## List Aliases

aws lambda list-aliases --function-name DATESTFUN

## Update the Function


aws lambda update-function-code --function-name DATESTFUN --zip-file fileb://function/function.zip

## Update the Alias

aws lambda update-alias --function-name DATESTFUN --name prod --function-version 2

## Create a Lambda Layer
 -- Lambda layer can be straight away published as a version, it cant be created. Ie no APi to create the layer
 aws lambda publish-layer-version --layer-name DATESTLA --zip-file fileb://layer/layer.zip

## Attach the layer to the function

aws lambda update-function-configuration \
  --function-name DATESTFUN \
  --layers $(aws lambda list-layer-versions --layer-name DATESTLA --query 'LayerVersions[0].LayerVersionArn' --output text)

## Run the function 

aws lambda invoke \
  --function-name DATESTFUN \
  --payload '{}' \
  response.json

### TroubleShooting

## Log-stream 

aws logs describe-log-streams --log-group-name /aws/lambda/DATESTFUN --order-by LastEventTime --descending --limit 1

*******************************************************************************************

✅ 1. Code Signing Config (CSC)
📌 What It Is:
A security feature to ensure that only trusted, signed code gets deployed to your Lambda.

📦 Use Case:
Let’s say your company wants to make sure no unauthorized developer uploads a Lambda ZIP file. You use AWS Signer to sign your code packages, and Lambda checks this signature before allowing deployment.

⚙️ Components:
Signing Profile (AWS Signer): This is like a digital certificate.
  -- To create a Code Signing Config for Lambda, you first need a Signing Profile ARN from AWS Signer. The signing profile represents the identity that signs your Lambda deployment packages

  --AWS Signer is a fully managed service that helps you digitally sign code or software packages to verify their authenticity and integrity before deployment.

CodeSigningConfig: Defines policies like:

What to do if the code is unsigned (Enforce or Warn)

Which signing profiles are allowed

🧠 Analogy:
Like verifying an app’s signature before installing it on your phone.

✅ 2. Function URL Config
📌 What It Is:
This allows your Lambda to have a dedicated HTTPS URL, so you can call it directly without using API Gateway.

📦 Use Case:
Suppose you have a lightweight function (like a contact form handler or webhook receiver). Instead of setting up API Gateway, you just create a Lambda Function URL.

⚙️ Features:
Supports NONE or AWS_IAM authentication

Simple to set up for webhooks or frontend integration

Has built-in CORS support

🧠 Analogy:
Like giving your Lambda its own website link: https://random-id.lambda-url.aws-region.on.aws/

✅ 3. Event Source Mapping
📌 What It Is:
This connects your Lambda to automatically trigger from another AWS service like:

SQS: New message → Lambda triggered

DynamoDB Streams

Kinesis Data Streams

MSK (Kafka)

📦 Use Case:
You want your Lambda to process SQS messages as they come in. You create a mapping between the SQS queue and your Lambda.

⚙️ What It Does:
Controls batch size, retry logic, etc.

Manages polling for you (e.g., for SQS or Kinesis)

Can be enabled/disabled

🧠 Analogy:
Like subscribing your Lambda to a messaging service. When messages arrive, Lambda is auto-notified and runs.