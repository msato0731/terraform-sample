terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  cloud {
    workspaces {
      name = "migrate-state-s3-tfc"
    }
  }
}
#   backend "s3" {
#     bucket         = "terraform-state-hoge"
#     key            = "terraform.tfstate"
#     region         = "ap-northeast-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-hoge"
#   }

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}
