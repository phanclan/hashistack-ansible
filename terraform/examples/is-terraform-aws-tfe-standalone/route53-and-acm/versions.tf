#Created with python
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.25.0"
    }
    template = {version = "~> 2.2.0"}
    acme = {
      source = "vancluever/acme"
      version = "~> 2.0.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  region = "us-west-2"
}
