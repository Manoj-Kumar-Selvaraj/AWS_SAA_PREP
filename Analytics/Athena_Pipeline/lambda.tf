# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/transfer_family_workflow"
  retention_in_days = 14
}

# Lambda Layer for pgpy
resource "aws_lambda_layer_version" "pgpy_layer" {
  filename            = "lambda_layer.zip"
  layer_name          = "pgpy-lib"
  compatible_runtimes = ["python3.11"]
  source_code_hash    = filebase64sha256("lambda_layer.zip")
}

# Lambda Function
resource "aws_lambda_function" "transfer_family_workflow" {
  function_name    = "transfer_family_workflow"
  role             = aws_iam_role.secrets_lambda_role.arn
  runtime          = "python3.11"
  filename         = "lambda_function.zip"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("lambda_function.zip")
  layers           = [aws_lambda_layer_version.pgpy_layer.arn]
  timeout          = 300

  environment {
    variables = {
      PGP_KEY_SECRET        = "AthenaPGPPrivateKey"
      PGP_PASSPHRASE_SECRET = "AthenaPGPPassphrase"
      EMAIL_SENDER          = "ss.mano1998@gmail.com"
      EMAIL_RECIPIENT       = "ss.mano1998@gmail.com"
      ENV                   = "Test"
      GLUE_CRAWLER_NAME     = "athena-pipeline-crawler"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_log_group,
    aws_iam_role_policy.lambda_cloudwatch_policy,
    aws_iam_role_policy.lambda_s3_access_policy,  # NEW: Ensure S3 permissions are ready
    aws_iam_role_policy.lambda_ses_policy         # NEW: Ensure SES permissions are ready
  ]
}

# IAM Policy for CloudWatch Logs (existing)
resource "aws_iam_role_policy" "lambda_cloudwatch_policy" {
  name = "LambdaCloudWatchPolicy"
  role = aws_iam_role.secrets_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# NEW: IAM Policy for S3 Access (fixes the "s3:GetObject" error)
resource "aws_iam_role_policy" "lambda_s3_access_policy" {
  name = "LambdaS3AccessPolicy"
  role = aws_iam_role.secrets_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::athena-test-manoj-1144",
          "arn:aws:s3:::athena-test-manoj-1144/*"
        ]
      }
    ]
  })
}

# NEW: IAM Policy for SES (fixes the "ses:SendRawEmail" error)
resource "aws_iam_role_policy" "lambda_ses_policy" {
  name = "LambdaSESPolicy"
  role = aws_iam_role.secrets_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "ses:FromAddress": "ss.mano1998@gmail.com"
          }
        }
      }
    ]
  })
}