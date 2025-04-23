resource "aws_s3_bucket" "Athena_Backend_Manager" {
  bucket = "athena-backend-manager-${random_integer.random_int.result}"
  object_lock_enabled = true
}

resource "aws_s3_bucket_public_access_block" "Athena_Backend_Manager_Block_Public" {
  bucket = aws_s3_bucket.Athena_Backend_Manager.id
  ignore_public_acls = true
  block_public_acls = true
  block_public_policy = false
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "Athena_Backend_Manager_Vr" {
  bucket = aws_s3_bucket.Athena_Backend_Manager.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "Athena_Backend_Manager_encryption" {
  bucket = aws_s3_bucket.Athena_Backend_Manager.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "terraform_state_policy" {
  bucket = aws_s3_bucket.Athena_Backend_Manager.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowTerraformUserAccess",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${data.aws_iam_user.current.user_name}"
        },
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.Athena_Backend_Manager.id}",
          "arn:aws:s3:::${aws_s3_bucket.Athena_Backend_Manager.id}/*"
        ]
      }
    ]
  })
}

resource "aws_dynamodb_table" "terraform_backend" {
  name         = "terraform_backend_table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Backend Table"
  }
}

