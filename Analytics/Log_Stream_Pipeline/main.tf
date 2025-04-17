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

resource "random_integer" "kinesis_random" {
  min = 1
  max = 10000
}

resource "aws_s3_bucket" "Kinesis_Bucket" {
  bucket              = "kinesis-bucket-${random_integer.kinesis_random.result}"
  object_lock_enabled = true
}

resource "aws_s3_bucket_public_access_block" "Kinesis_Block_Public" {
  bucket                  = aws_s3_bucket.Kinesis_Bucket.id
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = false
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "Kinesis_Bucket_Pol" {
  bucket = aws_s3_bucket.Kinesis_Bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "KinesisBucketPolicy"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.Kinesis_Bucket.arn}",
          "${aws_s3_bucket.Kinesis_Bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_kinesis_stream" "log_stream" {
  name             = "log-stream"
  shard_count      = 1
  retention_period = 24

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Environment = "test"
  }
}

resource "aws_iam_role" "data_streams_firehose" {
  name = "data_streams_firehose"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "firehose.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "firehose_policy" {
  name = "kinesis-firehose-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kinesis:Get*",
          "kinesis:DescribeStream",
          "cloudwatch:PutMetricData",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "s3:PutObject",
          "s3:GetBucketLocation"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_policy_attach" {
  role       = aws_iam_role.data_streams_firehose.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}

resource "aws_cloudwatch_log_group" "firehose_log_group" {
  name = "/aws/kinesisfirehose/firehose-to-s3"
}

resource "aws_cloudwatch_log_stream" "firehose_log_stream" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.firehose_log_group.name
}

resource "aws_kinesis_firehose_delivery_stream" "firehose_stream" {
  name        = "firehose-to-s3"
  destination = "extended_s3"

  depends_on = [
    aws_iam_role_policy_attachment.firehose_policy_attach
  ]

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.log_stream.arn
    role_arn           = aws_iam_role.data_streams_firehose.arn
  }

  extended_s3_configuration {
    role_arn           = aws_iam_role.data_streams_firehose.arn
    bucket_arn         = aws_s3_bucket.Kinesis_Bucket.arn
    buffering_size     = 5   # Size in MB
    buffering_interval = 60  # Interval in seconds
    compression_format = "UNCOMPRESSED"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/firehose-to-s3"
      log_stream_name = "S3Delivery"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
