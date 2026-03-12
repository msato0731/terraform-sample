################################################################################
# AWS VPC
################################################################################

terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.36"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = var.name
  cidr = var.cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.cidr, 8, k + 10)]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  # デフォルトセキュリティグループのルールを空にする（セキュリティベストプラクティス）
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  tags = var.tags
}
