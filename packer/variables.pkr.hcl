variable "myResourceGroup" {
  default = "vpphan-workshop"
}

# variable "myPackerImage" {
#   default = "hashistack-{{isotime \"2006-01-02\"}}"
# }

variable "myPackerImage2" {
  default = "jenkins-tf-ansible-vault"
}
variable "vm_size" {
  default = "Standard_DS2_v2"
}
#Standard_A2_v2
variable "location" {
  default = "West US 2"
}
variable "image_sku" {
  default = "18.04-LTS"
}
