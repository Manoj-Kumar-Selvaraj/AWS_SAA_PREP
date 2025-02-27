provider "aws" {
  region = "us-east-1"
}

# Create a KMS Customer Managed Key (CMK)
resource "aws_kms_key" "customer_managed_kms" {
  description             = "Customer Managed Key for Secure Encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true  # Enable key rotation for security

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid": "AllowRootAccountAccess",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "Allow access for Key Administrators",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::686255975511:user/GitPod"
        },
        "Action": [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
          "kms:RotateKeyOnDemand"
        ],
        "Resource": "*"
      },
      {
        "Sid": "Allow use of the key",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::686255975511:user/GitPod"
        },
        "Action": [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource": "*"
      },
      {
        "Sid": "Allow attachment of persistent resources",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::686255975511:user/GitPod"
        },
        "Action": [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        "Resource": "*",
        "Condition": {
          "Bool": {
            "kms:GrantIsForAWSResource": "true"
          }
        }
      }
    ]
  })
}

# Create an Alias for the KMS Key
resource "aws_kms_alias" "customer_kms_alias" {
  name          = "alias/customer-managed-key"
  target_key_id = aws_kms_key.customer_managed_kms.key_id
}

# Get AWS Account ID for policy
data "aws_caller_identity" "current" {}
