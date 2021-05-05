resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

# Create User
resource "vault_generic_endpoint" "u1" {
  for_each = var.username
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/${each.key}" #${var.username}"
  ignore_absent_fields = true

#   data_json = <<EOT
# {
#   "policies": ${jsonencode(var.policies)},
#   "password": "${var.password}"
# }
# EOT
  data_json = <<EOT
{
  "policies": ${jsonencode(var.policies)},
  "password": "${each.value}"
}
EOT

}

### Begin Review
# #=> Login with user
# resource "vault_generic_endpoint" "u1_token" {
#   for_each       = var.username
#   depends_on     = [vault_generic_endpoint.u1]
#   path           = "auth/userpass/login/${each.key}"#${var.username}"
#   disable_read   = true
#   disable_delete = true

# #   data_json = <<EOT
# # {
# #   "password": "${var.password}"
# # }
# # EOT
#   data_json = <<EOT
# {
#   "password": "${each.value}"
# }
# EOT
# }

# # Capture
# resource "vault_generic_endpoint" "u1_entity" {
#   for_each             = var.username
#   depends_on           = [vault_generic_endpoint.u1_token]
#   disable_read         = true
#   disable_delete       = true
#   path                 = "identity/lookup/entity"
#   ignore_absent_fields = true
#   write_fields         = ["id"]

# #   data_json = <<EOT
# # {
# #   "alias_name": "${var.username}",
# #   "alias_mount_accessor": "${vault_auth_backend.userpass.accessor}"
# # }
# # EOT
#   data_json = <<EOT
# {
#   "alias_name": "${each.key}",
#   "alias_mount_accessor": "${vault_auth_backend.userpass.accessor}"
# }
# EOT
# }

# output "u1_id" {
#   value = vault_generic_endpoint.u1_entity[*] #.write_data["id"]
# }
### END Review

output "mount_accessor" {
  value = vault_auth_backend.userpass.accessor
}

### Not sure what this is for
# output "userpass_entity_ids" {
#     description = "Show ids of userpass entities."
#     value = { for k, v in vault_generic_endpoint.u1_entity :
#       k => v.write_data.id} #.write_data.id } # ... if v.path != ""}
# }

variable "username" {
  description = "Name of the user"
}

variable "password" {
  description = "User Password.  This will be in clear text"
}

variable "policies" {
  default = ["training"]
}

variable "policies_entity" {
  default = ["training"]
}

variable "policies_entity_group" {
  default = ["training"]
}

#=> Creates an Identity Entity for Vault.
resource "vault_identity_entity" "this" {
  for_each             = var.username
  # provider = vault.education
  name     = each.key #"bob"
  policies = var.policies_entity
  metadata = {
    foo = "bar"
  }
}

output "this_vault_identity_entity_id" {
    value = vault_identity_entity.this[*]
}

#=> Creates an Identity Entity Alias for Vault.
resource "vault_identity_entity_alias" "this" {
  # provider = vault.education
  for_each             = var.username
  name            = each.key #"bob" #ex username from userpass backend
  mount_accessor  = vault_auth_backend.userpass.accessor
  canonical_id       = vault_identity_entity.this[each.key].id
#   canonical_id    = module.userpass.userpass_entity_ids["bob"]
}

# output "mount_accessor" {
#     value = module.userpass.mount_accessor
# }

#=> Create an Identity Group for Vault.
resource "vault_identity_group" "this" {
  # provider = vault.education
  # for_each             = var.username
  name            = "Training Admin2" #ex username from userpass backend
  type            = "internal" # default internal; future, convert to variable
  external_member_entity_ids = true # default false
  policies        = var.policies_entity_group
}
