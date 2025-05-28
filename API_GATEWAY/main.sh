#!/bin/bash

set -e

# 1. Create a new REST API
API_NAME="MyTestAPI"
echo "Creating REST API: $API_NAME"
API_ID=$(aws apigateway create-rest-api --name "$API_NAME" --query 'id' --output text)
echo "API ID: $API_ID"

# 2. Get the root resource ID ("/" path)
ROOT_ID=$(aws apigateway get-resources --rest-api-id $API_ID --query 'items[?path==`/`].id' --output text)
echo "Root Resource ID: $ROOT_ID"

# 3. Create GET method on root with no authorization
echo "Creating GET method..."
aws apigateway put-method --rest-api-id $API_ID --resource-id $ROOT_ID --http-method GET --authorization-type "NONE"

# 4. Setup MOCK integration for GET method (returns 200)
echo "Setting up MOCK integration for GET..."
aws apigateway put-integration --rest-api-id $API_ID --resource-id $ROOT_ID --http-method GET \
  --type MOCK \
  --request-templates '{"application/json": "{\"statusCode\": 200}"}'

# 5. Create method response for GET 200 with CORS header
echo "Creating method response for GET..."
aws apigateway put-method-response --rest-api-id $API_ID --resource-id $ROOT_ID --http-method GET --status-code 200 \
  --response-parameters method.response.header.Access-Control-Allow-Origin=true

# 6. Create integration response for GET 200 with CORS header set to '*'
echo "Creating integration response for GET..."
aws apigateway put-integration-response --rest-api-id $API_ID --resource-id $ROOT_ID --http-method GET --status-code 200 \
  --response-parameters '{"method.response.header.Access-Control-Allow-Origin":"*"}' \
  --selection-pattern ""

# 7. Create OPTIONS method for CORS preflight
echo "Creating OPTIONS method..."
aws apigateway put-method --rest-api-id $API_ID --resource-id $ROOT_ID --http-method OPTIONS --authorization-type "NONE"

# 8. Setup MOCK integration for OPTIONS method
echo "Setting up MOCK integration for OPTIONS..."
aws apigateway put-integration --rest-api-id $API_ID --resource-id $ROOT_ID --http-method OPTIONS \
  --type MOCK \
  --request-templates '{"application/json": "{\"statusCode\": 200}"}'

# 9. Create method response for OPTIONS declaring CORS headers
echo "Creating method response for OPTIONS..."
aws apigateway put-method-response --rest-api-id $API_ID --resource-id $ROOT_ID --http-method OPTIONS --status-code 200 \
  --response-parameters method.response.header.Access-Control-Allow-Headers=true \
  --response-parameters method.response.header.Access-Control-Allow-Methods=true \
  --response-parameters method.response.header.Access-Control-Allow-Origin=true

# 10. Create integration response for OPTIONS with CORS headers set
echo "Creating integration response for OPTIONS..."
aws apigateway put-integration-response --rest-api-id $API_ID --resource-id $ROOT_ID --http-method OPTIONS --status-code 200 \
  --response-parameters '{"method.response.header.Access-Control-Allow-Headers":"Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token","method.response.header.Access-Control-Allow-Methods":"OPTIONS,GET","method.response.header.Access-Control-Allow-Origin":"*"}' \
  --selection-pattern ""

# 11. Deploy the API to a stage called "test"
echo "Deploying API..."
DEPLOYMENT_ID=$(aws apigateway create-deployment --rest-api-id $API_ID --stage-name test --query 'id' --output text)
echo "Deployment ID: $DEPLOYMENT_ID"

# 12. Print the invoke URL
echo "API Invoke URL: https://$API_ID.execute-api.us-east-1.amazonaws.com/test/"
