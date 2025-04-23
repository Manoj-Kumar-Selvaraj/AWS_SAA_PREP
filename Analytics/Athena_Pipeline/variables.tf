variable "pgp_private_key" {
  description = "PGP private key for decrypting files"
  type        = string
  sensitive   = true
}
