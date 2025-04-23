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
