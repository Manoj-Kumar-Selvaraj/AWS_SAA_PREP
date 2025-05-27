# Create a REST API
API_ID=$(aws apigateway create-rest-api --name "MyTestAPI" --query 'id' --output text)
echo "API ID: $API_ID"

# Get the root resource ID (needed to create methods)
ROOT_ID=$(aws apigateway get-resources --rest-api-id $API_ID --query 'items[?path==`/`].id' --output text)
echo "Root Resource ID: $ROOT_ID"

# Create a GET method on root
aws apigateway put-method --rest-api-id $API_ID --resource-id $ROOT_ID --http-method GET --authorization-type "NONE"

# Set up a MOCK integration (so you can test the API without Lambda for now)
aws apigateway put-integration --rest-api-id $API_ID --resource-id $ROOT_ID --http-method GET \
  --type MOCK \
  --request-templates '{"application/json": "{\"statusCode\": 200}"}'

# Create a Method Response for HTTP 200
aws apigateway put-method-response --rest-api-id $API_ID --resource-id $ROOT_ID --http-method GET --status-code 200

# Create an Integration Response for HTTP 200
aws apigateway put-integration-response --rest-api-id $API_ID --resource-id $ROOT_ID --http-method GET --status-code 200 \
  --selection-pattern ""

# Deploy the API
DEPLOYMENT_ID=$(aws apigateway create-deployment --rest-api-id $API_ID --stage-name test --query 'id' --output text)
echo "Deployment ID: $DEPLOYMENT_ID"

# Construct the invoke URL
echo "Invoke URL: https://$API_ID.execute-api.us-east-1.amazonaws.com/test/"
