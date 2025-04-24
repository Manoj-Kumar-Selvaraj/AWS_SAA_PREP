resource "aws_s3_bucket" "Athena_Test_Logging_Target" {
  bucket = "athena-test-logs-${random_integer.random_int.result}"
  tags = {
    Name = "Athena Logging Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "logging_target_block" {
  bucket                  = aws_s3_bucket.Athena_Test_Logging_Target.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "logging_target_policy" {
  bucket = aws_s3_bucket.Athena_Test_Logging_Target.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "S3ServerAccessLogsPolicy",
        Effect = "Allow",
        Principal = {
          Service = "logging.s3.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.Athena_Test_Logging_Target.arn}/athena-access-logs/*",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_logging" "athena_test_logging" {
  bucket        = aws_s3_bucket.Athena_Test.id
  target_bucket = aws_s3_bucket.Athena_Test_Logging_Target.id
  target_prefix = "athena-access-logs/"
}
