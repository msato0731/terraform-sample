terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.90.1"
    }
  }
  # backend "s3" {}
  # ローカルからterraform cli実行にはcloudブロックが必要
  cloud {}
}

provider "aws" {
  region = "ap-northeast-1"
}

variable "env" {
  description = "The environment name"
  type        = string
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.env}"
  }
}
