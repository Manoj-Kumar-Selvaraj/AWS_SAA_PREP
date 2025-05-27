## Creating IAM POLICY AND ROLE

$ aws iam create-policy --policy-name Lambda-Policy --policy-document file://lambda_policy.json --tags Key=Name,Value=DEVAS

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

## Create a Lambda Layer


