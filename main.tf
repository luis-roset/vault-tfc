provider "vault" {
  address = "http://localhost:8800"
  token   = var.vault_token
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "vault_kv_secret_v2" "ssh_keys" {
  path = "secret/data/ssh_keys"

  data_json = jsonencode({
    private_key = tls_private_key.example.private_key_pem
    public_key  = tls_private_key.example.public_key_openssh
  })
}

data "vault_generic_secret" "example" {
  path = "secret/data/ssh_keys"
}

output "private_key" {
  value = data.vault_generic_secret.example.data["private_key"]
}