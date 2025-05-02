variable "pgp_private_key" {
  description = "PGP private key for decrypting files"
  type        = string
  sensitive   = true
}

variable "pgp_passphrase" {
  type      = string
  sensitive = true
}

variable "trans_server_user_pass" {
  sensitive   = true
  description = "Password for setting up transfer family user"
  type        = string
}