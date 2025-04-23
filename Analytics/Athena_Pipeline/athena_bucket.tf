resource "aws_s3_bucket" "Athena_Test" {
  bucket              = "athena-test-manoj-${random_integer.random_int.result}"
  object_lock_enabled = true
  tags = {
    Name = "Athena Test"
  }
}

resource "aws_s3_bucket_public_access_block" "athena_test_block" {
  bucket = aws_s3_bucket.Athena_Test.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "athena_test_block_versioning" {
  bucket = aws_s3_bucket.Athena_Test.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_test_block_lifecycle_config" {
  bucket = aws_s3_bucket.Athena_Test.id
  rule {
    id     = "rule1"
    filter { prefix = "" }
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 90
      storage_class = "INTELLIGENT_TIERING"
    }
    transition {
      days          = 180
      storage_class = "GLACIER_IR"
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "athena_test_block_obj_lock_config" {
  bucket = aws_s3_bucket.Athena_Test.id
  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 5
    }
  }
}

resource "aws_s3_bucket_policy" "athena_test_block_policy" {
  bucket = aws_s3_bucket.Athena_Test.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AthenaBucketPolicy",
        Effect = "Allow",
        Principal = {
          Service = "athena.amazonaws.com"
        },
        Action = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          aws_s3_bucket.Athena_Test.arn,
          "${aws_s3_bucket.Athena_Test.arn}/*"
        ],
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AllowS3UploadViaTransferFamily",
        Effect = "Allow",
        Principal = {
          Service = "transfer.amazonaws.com"
        },
        Action = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
        Resource = [
          aws_s3_bucket.Athena_Test.arn,
          "${aws_s3_bucket.Athena_Test.arn}/*"
        ],
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_test_encryption" {
  bucket = aws_s3_bucket.Athena_Test.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
