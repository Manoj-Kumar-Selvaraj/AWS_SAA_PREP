terraform {
  backend "s3" {
    bucket         = "athena-backend-manager-1144"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_backend_table"
    encrypt        = true
  }
}
