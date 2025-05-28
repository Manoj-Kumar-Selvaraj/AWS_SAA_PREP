#!/bin/bash
set -e

# ======================= CONFIG ==========================
REGION="us-east-1"
TABLE_NAME="Users"
PARTITION_KEY="UserID"
SORT_KEY="Email"
READ_CAPACITY=5
WRITE_CAPACITY=5

echo "✅ Creating DynamoDB Table with On-Demand Capacity..."

aws dynamodb create-table \
  --table-name $TABLE_NAME \
  --attribute-definitions AttributeName=$PARTITION_KEY,AttributeType=S AttributeName=$SORT_KEY,AttributeType=S \
  --key-schema AttributeName=$PARTITION_KEY,KeyType=HASH AttributeName=$SORT_KEY,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION \
  --stream-specification StreamEnabled=true,StreamViewType=NEW_AND_OLD_IMAGES

echo "⏳ Waiting for table to become ACTIVE..."
aws dynamodb wait table-exists --table-name $TABLE_NAME --region $REGION

echo "✅ Table created: $TABLE_NAME"

# ========== Add Data ==========
echo "📥 Inserting item..."

aws dynamodb put-item \
  --table-name $TABLE_NAME \
  --item '{
    "UserID": {"S": "user123"},
    "Email": {"S": "john@example.com"},
    "Name": {"S": "John"},
    "Age": {"N": "30"}
  }' \
  --region $REGION

# ========== Read Data ==========
echo "📤 Fetching item..."

aws dynamodb get-item \
  --table-name $TABLE_NAME \
  --key '{
    "UserID": {"S": "user123"},
    "Email": {"S": "john@example.com"}
  }' \
  --region $REGION

# ========== Update Item ==========
echo "✏️ Updating Age..."

aws dynamodb update-item \
  --table-name $TABLE_NAME \
  --key '{
    "UserID": {"S": "user123"},
    "Email": {"S": "john@example.com"}
  }' \
  --update-expression "SET Age = :newAge" \
  --expression-attribute-values '{":newAge": {"N": "31"}}' \
  --region $REGION

# ========== Query Items ==========
echo "🔎 Querying all emails for UserID = user123..."

aws dynamodb query \
  --table-name $TABLE_NAME \
  --key-condition-expression "UserID = :uid" \
  --expression-attribute-values '{":uid": {"S": "user123"}}' \
  --region $REGION

# ========== Delete Item ==========
echo "❌ Deleting item..."

aws dynamodb delete-item \
  --table-name $TABLE_NAME \
  --key '{
    "UserID": {"S": "user123"},
    "Email": {"S": "john@example.com"}
  }' \
  --region $REGION

# ========== Enable Point-in-Time Recovery ==========
echo "🔁 Enabling Point-in-Time Recovery (PITR)..."

aws dynamodb update-continuous-backups \
  --table-name $TABLE_NAME \
  --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true \
  --region $REGION

echo "✅ All done!"
