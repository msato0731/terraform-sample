terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      System    = "ecs-bluegreen-native"
      Terraform = "true"
      Repo      = "msato0731/terraform-sample"
    }
  }
}
