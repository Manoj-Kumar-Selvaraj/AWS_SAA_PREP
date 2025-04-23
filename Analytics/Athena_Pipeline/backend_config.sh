#!/bin/bash

# Define Terraform state resource names
BUCKET_RESOURCE="aws_s3_bucket.Athena_Backend_Manager"
DYNAMO_RESOURCE="aws_dynamodb_table.terraform_backend"

# Dump the state to temp files
terraform state show "$BUCKET_RESOURCE" > s3_debug.txt
terraform state show "$DYNAMO_RESOURCE" > dynamo_debug.txt

# Extract using correct pattern
BUCKET_NAME=$(grep -E '^ *bucket *=' s3_debug.txt | sed -E 's/.*= *"([^"]+)".*/\1/')
DYNAMO_TABLE_NAME=$(terraform state show "$DYNAMO_RESOURCE" | awk '/^ *name *=/ {gsub(/"/, "", $3); print $3; exit}')

# Check and output result
if [[ -z "$BUCKET_NAME" || -z "$DYNAMO_TABLE_NAME" ]]; then
  echo "❌ ERROR: Could not extract bucket or DynamoDB table name."
  echo "Bucket Name: $BUCKET_NAME"
  echo "DynamoDB Table Name: $DYNAMO_TABLE_NAME"
  exit 1
fi

# Create backend.tf
cat <<EOF > backend.tf
terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "$DYNAMO_TABLE_NAME"
    encrypt        = true
  }
}
EOF

echo "✅ backend.tf created!"
echo "📦 Bucket: $BUCKET_NAME"
echo "🗄  DynamoDB Table: $DYNAMO_TABLE_NAME"
