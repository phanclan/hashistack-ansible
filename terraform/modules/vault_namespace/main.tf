resource "vault_namespace" "this" {
  path = var.path
}

variable "path" {
  description = "The path of the namespace. Must not have a trailing /"
  default = "ns1"
}

output "namespace_id" {
  value = "vault_namespace.this.id"
}