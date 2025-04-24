# Store PGP Private Key
resource "aws_secretsmanager_secret" "athena_pgp_key" {
  name        = "AthenaPGPPrivateKey"
  description = "PGP private key for Athena Pipeline decryption"
  tags = {
    Name        = "AthenaPGPPrivateKey"
    Environment = "Dev"
    Project     = "AthenaPipeline"
  }
}

resource "aws_secretsmanager_secret_version" "athena_pgp_key_version" {
  secret_id     = aws_secretsmanager_secret.athena_pgp_key.id
  secret_string = var.pgp_private_key
}

# Store PGP Passphrase
resource "aws_secretsmanager_secret" "athena_pgp_passphrase" {
  name        = "AthenaPGPPassphrase"
  description = "Passphrase for unlocking Athena PGP key"
  tags = {
    Name        = "AthenaPGPPassphrase"
    Environment = "Dev"
    Project     = "AthenaPipeline"
  }
}

resource "aws_secretsmanager_secret_version" "athena_pgp_passphrase_version" {
  secret_id     = aws_secretsmanager_secret.athena_pgp_passphrase.id
  secret_string = var.pgp_passphrase
}

# IAM Policy for Lambda to access both secrets
resource "aws_iam_policy" "secrets_lambda_policy" {
  name = "SecretsLambdaPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "AllowPGPKey",
        Effect : "Allow",
        Action : "secretsmanager:GetSecretValue",
        Resource : aws_secretsmanager_secret.athena_pgp_key.arn
      },
      {
        Sid : "AllowPGPPassphrase",
        Effect : "Allow",
        Action : "secretsmanager:GetSecretValue",
        Resource : aws_secretsmanager_secret.athena_pgp_passphrase.arn
      }
    ]
  })
}

# IAM Role for Lambda
resource "aws_iam_role" "secrets_lambda_role" {
  name = "secrets-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach the policy to the role
resource "aws_iam_policy_attachment" "secrets_lambda_policy_attachment" {
  name       = "AttachSecretsPolicy"
  roles      = [aws_iam_role.secrets_lambda_role.name]
  policy_arn = aws_iam_policy.secrets_lambda_policy.arn
}

