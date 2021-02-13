module "aws_key_pair" {
  source = "cloudposse/key-pair/aws"
  namespace             = "pphan"
  stage                 = "dev"
  name                  = "tfe"
  environment           = "usw-2"
  ssh_public_key_path = var.ssh_public_key_path
  generate_ssh_key    = var.generate_ssh_key

  # context = module.this.context
}

output "key_name" {
  value       = module.aws_key_pair.key_name
  description = "Name of SSH key"
}

output "public_key" {
  value       = module.aws_key_pair.public_key
  description = "Content of the generated public key"
}

output "public_key_filename" {
  description = "Public Key Filename"
  value       = module.aws_key_pair.public_key_filename
}

output "private_key_filename" {
  description = "Private Key Filename"
  value       = module.aws_key_pair.private_key_filename
}

variable "name" {
  type        = string
  default     = null
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "namespace" {
  type        = string
  default     = null
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key directory (e.g. `/secrets`)"
}

variable "stage" {
  type        = string
  default     = null
  description = "Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'"
}

variable "generate_ssh_key" {
  type        = bool
  description = "If set to `true`, new SSH key pair will be created"
}

