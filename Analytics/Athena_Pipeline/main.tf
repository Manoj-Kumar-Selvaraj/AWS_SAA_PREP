# Terraform Project Structure: Athena_Pipeline
#
# File Breakdown:
#
# - provider.tf              : AWS provider configuration (region, credentials, etc.)
# - backend.tf               : Remote backend setup using S3 and DynamoDB
# - backend_resources.tf     : Resources for S3 bucket and DynamoDB table used in backend
# - athena_bucket.tf         : S3 buckets used for Athena queries and results
# - logging.tf               : Logging configuration for services (like S3, CloudTrail, etc.)
# - vpc.tf                   : VPC, subnets, and related networking components
# - transfer_family.tf       : AWS Transfer Family setup (FTP/SFTP)
# - main.tf                  : (This file) - serves as the entrypoint; currently acts as a project map
# - Keys/                    : Directory to store SSH keys or public/private key material
# - Files/                   : Sample files or data (input/output/testing purposes)
# - Outbound.sh              : Shell script for outbound data processing/transfers
# - issues.md                : Markdown file to track current issues, bugs, or enhancements
