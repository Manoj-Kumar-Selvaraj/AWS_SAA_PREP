terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_user" "current" {
  user_name = data.aws_caller_identity.current.arn != "" ? split("/", data.aws_caller_identity.current.arn)[1] : ""
}

resource "random_integer" "random_int" {
  min = 1000
  max = 20000
}
