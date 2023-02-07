terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  cloud {
    organization = "classmethod-sandbox"
    hostname = "app.terraform.io"

    workspaces {
      name = "migrate-state-s3-tfc"
    }
  }
}
#   backend "s3" {
#     bucket         = "terraform-state-201472471660-02"
#     key            = "terraform.tfstate"
#     region         = "ap-northeast-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-201472471660-02"
#   }
# }

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}