#==> 1. Configure local vault.
module "vault_base" {
  source = "../modules/vault_base"
}

#==> 2. Build Azure RG and Vault Secrets Engine
module "network" {
  source = "../modules/azure_network"
  common_tags = local.common_tags
  prefix = var.prefix
  rg_name = "${var.prefix}-jenkins"
}


# module "azure_secrets_engine" {
#   source = "../modules/azure_secrets_engine"
#   client_secret = var.client_secret
#   client_id = var.client_id
#   common_tags = local.common_tags
#   location = "westus2"
#   rg_name = "${var.prefix}-jenkins"
#   prefix = var.prefix
#   subscription_id = var.subscription_id
#   tenant_id = var.tenant_id
# }

# module "jenkins" {
#   source = "../modules/jenkins_secure_introduction"
# }

# module "build_jenkins_vm" {
#   source = "../modules/build_jenkins_vm/Terraform/BuildJenkinsVM"
#   depends_on = [module.azure_secrets_engine]
#   common_tags = local.common_tags
#   location    = "westus2"
#   prefix = local.prefix
#   source_image_id = "jenkins-tf-ansible-vault"
#   public_key = file("/Users/pephan/.ssh/id_rsa.pub")
#   resource_group_name = module.azure_secrets_engine.azurerm_resource_group
#   vm_size = "Standard_B2s" # B1s, B2s, A1v2, A2v2
# }



locals {
  se-region = "AMER - NorCal"
  owner     = "peter.phan"
  purpose   = "demo for end-to-end infrastructure and application deployments"
  ttl       = "8"
  terraform = "true"
  prefix    = "pphan"
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    se-region = local.se-region
    owner     = local.owner
    purpose   = local.purpose
    ttl       = local.ttl
    terraform = local.terraform
  }
}