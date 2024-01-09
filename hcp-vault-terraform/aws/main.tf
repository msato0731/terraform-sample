terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.23.0"
    }
  }
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "terraform_remote_state" "vault" {
  backend = "local"

  config = {
    path = "../vault/terraform.tfstate"
  }
}

data "vault_aws_access_credentials" "creds" {
  backend = data.terraform_remote_state.vault.outputs.backend
  role    = data.terraform_remote_state.vault.outputs.role
}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
}

resource "aws_s3_bucket" "main" {
  bucket = "vault-test-20240105" # 一意な名前を指定してください
}
