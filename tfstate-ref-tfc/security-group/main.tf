terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
  required_version = "1.4.6"
}

provider "aws" {
  region = "ap-northeast-1"
}

# VPC WorkspaceのState取得
data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "<Organization名>" # 要修正
    workspaces = {
      name = "tfstate-ref-tfc-test-vpc"
    }
  }
}

resource "aws_security_group" "test" {
  name        = "test"
  description = "test"
  # VPC ID取得
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
}
