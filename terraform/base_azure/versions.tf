terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # version = "2.36.0"
    }
  }
}

provider "azurerm" {
  features {}
}