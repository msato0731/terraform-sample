variable "instance_type" {
  description = "Type of EC2 instance to use"
  default     = "t2.micro"
  type        = string
}

variable "tags" {
  description = "Tags for instances"
  type        = map(any)
  default     = {}
}

variable "aws_region" {
  type        = string
  default     = "ap-northeast-1"
  description = "AWS region for all resources"
}


resource "tfe_organization" "main" {
  name  = "my-org-name"
  email = "admin@company.com"
}

resource "tfe_workspace" "test" {
  name         = "test-workspace"
  organization = tfe_organization.main.name
}

resource "tfe_workspace" "stg" {
  name         = "stg-workspace"
  organization = tfe_organization.main.name
}

resource "tfe_workspace" "prod" {
  name         = "prod-workspace"
  organization = tfe_organization.main.name
}

