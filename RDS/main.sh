#!/bin/bash
set -e

# --- BASIC CONFIG ---
REGION="us-east-1"
CIDR_VPC="10.0.0.0/22"
CIDR_SUBNET="10.0.1.0/24"
DB_PORT=3306

# --- RDS CONFIG ---
DB_INSTANCE_IDENTIFIER="mydb-instance"
DB_INSTANCE_CLASS="db.t3.micro"
ENGINE="mysql"
ENGINE_VERSION="8.0.35"
ALLOCATED_STORAGE=20
MASTER_USERNAME="admin"
MASTER_USER_PASSWORD="YourStrongPassword123!"
DB_NAME="mydatabase"
PUBLIC_ACCESSIBLE="true"
BACKUP_RETENTION_DAYS=7
AUTO_MINOR_VERSION_UPGRADE="true"
STORAGE_TYPE="gp2"
TAG_KEY="Environment"
TAG_VALUE="Dev"

# --- Create VPC, Subnet, Internet Gateway ---
VPC_ID=$(aws ec2 create-vpc --cidr-block $CIDR_VPC --region $REGION --query 'Vpc.VpcId' --output text)
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $CIDR_SUBNET --region $REGION --query 'Subnet.SubnetId' --output text)
IGW_ID=$(aws ec2 create-internet-gateway --region $REGION --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region $REGION
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --region $REGION --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --region $REGION
aws ec2 associate-route-table --route-table-id $ROUTE_TABLE_ID --subnet-id $SUBNET_ID --region $REGION
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch --region $REGION

# --- Create Security Group ---
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name "rds-sg" --description "Allow MySQL" --vpc-id $VPC_ID --region $REGION --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port $DB_PORT --cidr 0.0.0.0/0 --region $REGION

# --- Create DB Subnet Group ---
DB_SUBNET_GROUP=$(aws rds create-db-subnet-group \
  --db-subnet-group-name "${DB_INSTANCE_IDENTIFIER}-subnet-group" \
  --db-subnet-group-description "Subnet group for $DB_INSTANCE_IDENTIFIER" \
  --subnet-ids $SUBNET_ID \
  --region $REGION \
  --query 'DBSubnetGroup.DBSubnetGroupName' --output text)

# --- Create Parameter Group ---
PARAMETER_GROUP_NAME="${DB_INSTANCE_IDENTIFIER}-param-group"
aws rds create-db-parameter-group \
  --db-parameter-group-name $PARAMETER_GROUP_NAME \
  --db-parameter-group-family "mysql8.0" \
  --description "Custom parameter group" \
  --region $REGION

# Optional: Modify parameters (example: enable slow query log)
aws rds modify-db-parameter-group \
  --db-parameter-group-name $PARAMETER_GROUP_NAME \
  --parameters "ParameterName=slow_query_log,ParameterValue=1,ApplyMethod=immediate" \
  --region $REGION

aws rds modify-db-parameter-group \
  --db-parameter-group-name $PARAMETER_GROUP_NAME \
  --parameters "ParameterName=max_connections,ParameterValue=300,ApplyMethod=pending-reboot" \
  --region $REGION

# --- Create Option Group ---
OPTION_GROUP_NAME="${DB_INSTANCE_IDENTIFIER}-opt-group"
aws rds create-option-group \
  --option-group-name $OPTION_GROUP_NAME \
  --engine-name $ENGINE \
  --major-engine-version "8.0" \
  --option-group-description "Custom Option Group" \
  --region $REGION

# --- Create RDS ---
aws rds create-db-instance \
  --db-instance-identifier "$DB_INSTANCE_IDENTIFIER" \
  --db-instance-class "$DB_INSTANCE_CLASS" \
  --engine "$ENGINE" \
  --engine-version "$ENGINE_VERSION" \
  --allocated-storage "$ALLOCATED_STORAGE" \
  --master-username "$MASTER_USERNAME" \
  --master-user-password "$MASTER_USER_PASSWORD" \
  --db-name "$DB_NAME" \
  --vpc-security-group-ids "$SECURITY_GROUP_ID" \
  --db-subnet-group-name "$DB_SUBNET_GROUP" \
  --backup-retention-period "$BACKUP_RETENTION_DAYS" \
  --publicly-accessible $PUBLIC_ACCESSIBLE \
  --storage-type "$STORAGE_TYPE" \
  --auto-minor-version-upgrade $AUTO_MINOR_VERSION_UPGRADE \
  --db-parameter-group-name "$PARAMETER_GROUP_NAME" \
  --option-group-name "$OPTION_GROUP_NAME" \
  --deletion-protection \
  --enable-cloudwatch-logs-exports "error" "slowquery" \
  --enable-iam-database-authentication \
  --enable-storage-auto-scaling \
  --tags Key="$TAG_KEY",Value="$TAG_VALUE" \
  --region "$REGION"

echo "RDS instance '$DB_INSTANCE_IDENTIFIER' is being created."
