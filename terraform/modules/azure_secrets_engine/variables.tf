# variable "DB_USER" {
#   description = "mongodb username"
# }

# variable "DB_PASSWORD" {
#   description = "mongodb password"
# }

# variable "DB_URL" {
#   description = "mongodb URL"
# }

# variable "DB_URL_NOMAD" {
#   description = "mongodb URL for the nomad cluster for the webblog demo"
# }

# variable "DB_URL_AZURE" {
#   description = "mongodb URL for the webblog demo on Azure for end-to-end deployment"
# }

variable "subscription_id" {
  description = "Azure subscription_id"
}

variable "tenant_id" {
  description = "Azure tenant_id"
}

variable "client_secret" {
  description = "Azure client_secret"
}

variable "client_id" {
  description = "Azure client_id"
}

variable "common_tags" {
  description = "Common tags for objects"
}

variable "prefix" {
  description = "This prefix will be included in the name of most resources."
  default     = "pphan"
}

variable "location" {
  description = "The region where the virtual network is created."
  default     = "westus2" # az account list-locations -o table | grep US
}

variable "rg_name" {}