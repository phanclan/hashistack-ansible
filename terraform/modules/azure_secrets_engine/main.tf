# Azure Secrets Engine Configuration
# resource "azurerm_resource_group" "myresourcegroup" {
#   name     = var.rg_name
#   location = var.location

#   tags = var.common_tags
# }

# data "azurerm_resource_group" "example" {
#   name = "existing"
# }

resource "vault_azure_secret_backend" "azure" {
  subscription_id = var.subscription_id
  tenant_id = var.tenant_id
  client_secret = var.client_secret
  client_id = var.client_id
}

resource "vault_azure_secret_backend_role" "jenkins" {
  backend                     = vault_azure_secret_backend.azure.path
  role                        = "jenkins"
  ttl                         = "300" # 86400 sec = 24h
  max_ttl                     = "600" # 172800 sec = 48h

  azure_roles {
    role_name = "Contributor"
    # scope =  "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.myresourcegroup.name}"
    scope =  "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}"
  }
}
