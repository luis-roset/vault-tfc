provider "vault" {
  address = "http://localhost:8800"
  token   = var.vault_token
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "vault_mount" "kvv2" {
  path        = "kvv2"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "ssh_keys" {
  mount                      = vault_mount.kvv2.path
  name                       = "ssh_keys"

  data_json = jsonencode({
    private_key = tls_private_key.example.private_key_pem
    public_key  = tls_private_key.example.public_key_openssh
  })
}

data "vault_generic_secret" "example" {
  path = vault_kv_secret_v2.ssh_keys.path
}

output "private_key" {
  value = data.vault_generic_secret.example.data["private_key"]
}