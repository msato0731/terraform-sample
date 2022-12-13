provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      System    = "pike-demo"
      Terraform = "true"
      Repo      = "msato0731/terraform-sample"
    }
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.26.0"
    }
  }
  required_version = "1.3.4"
}

terraform {
  backend "s3" {
    key            = "pike-demo.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "terraform_state_lock"
  }
}
