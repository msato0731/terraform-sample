terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.67"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy = "Terraform"
    }
  }
}

provider "awscc" {
  region = var.region
}

# IAM Identity Center (Account Instance)
resource "awscc_sso_instance" "this" {
  name = var.instance_name

  tags = [{
    key   = "ManagedBy"
    value = "Terraform"
  }]
}

# Identity Store User
resource "aws_identitystore_user" "this" {

  identity_store_id = awscc_sso_instance.this.identity_store_id
  display_name      = join(" ", [var.user_given_name, var.user_family_name])
  user_name         = var.user_email

  name {
    family_name = var.user_family_name
    given_name  = var.user_given_name
  }

  emails {
    value   = var.user_email
    primary = true
  }
}
