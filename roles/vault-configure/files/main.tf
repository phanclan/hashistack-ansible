resource "vault_policy" "example" {
  name = "dr-secondary-promotion"

  policy = <<EOT
path "*" {
  capabilities = ["update"]
}
path "sys/replication/dr/secondary/promote" {
  capabilities = [ "update" ]
}

path "sys/replication/dr/secondary/update-primary" {
   capabilities = [ "update" ]
}
EOT
}

# Create a token role named "failover-handler" with the dr-secondary-promotion
# policy attached and its type should be batch
resource "vault_token_auth_backend_role" "example" {
  role_name           = "failover-handler"
  allowed_policies    = [vault_policy.example.name]
  orphan              = true
  renewable           = false
  token_type          = "batch"
}

# Create a token for role "failover-handler" with TTL set to 8 hours.
# vault token create -role=failover-handler -ttl=8h
resource "vault_token" "example3" {
  # role_name = "failover-handler" #vault_token_auth_backend_role.example.role_name
  # policies = [vault_policy.example.name, "default"]
  ttl = "8h"
  # renew_min_lease = 43200
  # renew_increment = 86400
  # gpg_key = "keybase:my_username"
}

output "token_accessor" {
  value = vault_token.example3.id
}