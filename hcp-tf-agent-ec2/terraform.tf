terraform {
  required_version = "~> 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.99.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.66.0"
    }
  }
  cloud {}
}
