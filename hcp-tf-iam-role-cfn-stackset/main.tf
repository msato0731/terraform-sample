terraform {
  required_version = ">= 1.11.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.82.2"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.62.0"
    }
  }
  cloud {
    # VCSとの接続を行わない場合、以下の設定 または、 環境変数の設定が必要
    # https://developer.hashicorp.com/terraform/language/terraform#tf_cloud_hostname
    # organization = ""
    # workspaces {
    #   project = ""
    #   name    = ""
    # }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "tfe" {
  organization = var.hcp_tf_organization_name
}

resource "aws_cloudformation_stack_set" "this" {
  name             = "hcp-tf-role"
  permission_model = "SERVICE_MANAGED"

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  parameters = {
    HCPTerraformOrgName     = var.hcp_tf_organization_name
    HCPTerraformIAMRoleName = var.hcp_tf_iam_role_name
  }
  template_body = file("${path.module}/files/cfn.yaml")
  capabilities  = ["CAPABILITY_NAMED_IAM"]
}


resource "aws_cloudformation_stack_set_instance" "this" {
  stack_set_name = aws_cloudformation_stack_set.this.name
  deployment_targets {
    organizational_unit_ids = [var.aws_ou_id]
  }
  region = var.aws_region
}

data "aws_organizations_organization" "org" {}

data "aws_organizations_organizational_unit_child_accounts" "accounts" {
  parent_id = var.aws_ou_id
}

locals {
  accounts_map = { for account in data.aws_organizations_organizational_unit_child_accounts.accounts.accounts : account.id => account }
}

resource "tfe_variable_set" "this" {
  for_each    = local.accounts_map
  name        = "auth-aws-${each.key}"
  description = "AWS credentials for ${each.value.name}"
}

resource "tfe_variable" "aws_provider_auth" {
  for_each = tfe_variable_set.this

  key             = "TFC_AWS_PROVIDER_AUTH"
  value           = "true"
  category        = "env"
  variable_set_id = each.value.id
}

resource "tfe_variable" "aws_run_role_arn" {
  for_each = tfe_variable_set.this

  key = "TFC_AWS_RUN_ROLE_ARN"
  # StackインスタンスのOutputをStackSet実行アカウントでは取得できないため、IAMロールのARNを直接指定する
  value           = "arn:aws:iam::${each.key}:role/${var.hcp_tf_iam_role_name}"
  category        = "env"
  variable_set_id = each.value.id
}
