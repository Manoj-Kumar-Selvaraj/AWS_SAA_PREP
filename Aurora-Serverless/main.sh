#!/bin/bash

set -e

# ===== CONFIGURABLE VARIABLES =====
REGION="us-east-1"
VPC_CIDR="10.0.0.0/16"
SUBNET1_CIDR="10.0.1.0/24"
SUBNET2_CIDR="10.0.2.0/24"
CLUSTER_NAME="aurora-serverless-cluster"
DB_NAME="mydb"
DB_USERNAME="admin"
DB_PASSWORD="MySecurePwd123!"
SECRET_NAME="aurora-serverless-secret"
ENGINE="aurora-mysql"
ENGINE_VERSION="8.0.mysql_aurora.3.04.0"
INSTANCE_CLASS="db.serverless"
TAG_KEY="Environment"
TAG_VALUE="Dev"

echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --query 'Vpc.VpcId' --output text --region $REGION)
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support "{\"Value\":true}" --region $REGION
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames "{\"Value\":true}" --region $REGION

echo "Creating Subnets..."
SUBNET1_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET1_CIDR --availability-zone ${REGION}a --query 'Subnet.SubnetId' --output text --region $REGION)
SUBNET2_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET2_CIDR --availability-zone ${REGION}b --query 'Subnet.SubnetId' --output text --region $REGION)

echo "Creating Internet Gateway and attaching..."
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text --region $REGION)
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region $REGION

echo "Creating Route Table and associating..."
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text --region $REGION)
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --region $REGION
aws ec2 associate-route-table --route-table-id $ROUTE_TABLE_ID --subnet-id $SUBNET1_ID --region $REGION
aws ec2 associate-route-table --route-table-id $ROUTE_TABLE_ID --subnet-id $SUBNET2_ID --region $REGION

echo "Creating Security Group..."
SG_ID=$(aws ec2 create-security-group --group-name AuroraSG --description "Aurora SG" --vpc-id $VPC_ID --query 'GroupId' --output text --region $REGION)
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 3306 --cidr 0.0.0.0/0 --region $REGION

echo "Creating DB Subnet Group..."
aws rds create-db-subnet-group \
  --db-subnet-group-name "aurora-subnet-group" \
  --db-subnet-group-description "Aurora Subnet Group" \
  --subnet-ids $SUBNET1_ID $SUBNET2_ID \
  --region $REGION

echo "Creating Secrets Manager secret..."
SECRET_ARN=$(aws secretsmanager create-secret \
  --name $SECRET_NAME \
  --description "Aurora credentials" \
  --secret-string "{\"username\":\"$DB_USERNAME\",\"password\":\"$DB_PASSWORD\"}" \
  --query ARN --output text \
  --region $REGION)

echo "Creating Aurora Serverless v2 Cluster..."
CLUSTER_ARN=$(aws rds create-db-cluster \
  --db-cluster-identifier $CLUSTER_NAME \
  --engine $ENGINE \
  --engine-version $ENGINE_VERSION \
  --database-name $DB_NAME \
  --master-username $DB_USERNAME \
  --master-user-password $DB_PASSWORD \
  --vpc-security-group-ids $SG_ID \
  --db-subnet-group-name "aurora-subnet-group" \
  --enable-http-endpoint \
  --scaling-configuration MinCapacity=0.5,MaxCapacity=2 \
  --tags Key=$TAG_KEY,Value=$TAG_VALUE \
  --region $REGION \
  --query DBCluster.DBClusterArn --output text)

echo "Creating Aurora DB Instance..."
aws rds create-db-instance \
  --db-instance-identifier "${CLUSTER_NAME}-instance" \
  --db-cluster-identifier $CLUSTER_NAME \
  --engine $ENGINE \
  --db-instance-class $INSTANCE_CLASS \
  --region $REGION

# Output info
echo "=========================================="
echo "✅ Cluster ARN: $CLUSTER_ARN"
echo "✅ Secret ARN:  $SECRET_ARN"
echo "You can test SQL using:"
echo ""
echo "aws rds-data execute-statement \\"
echo "  --resource-arn \"$CLUSTER_ARN\" \\"
echo "  --secret-arn \"$SECRET_ARN\" \\"
echo "  --database \"$DB_NAME\" \\"
echo "  --sql \"SELECT NOW();\" \\"
echo "  --region $REGION"
echo "=========================================="
