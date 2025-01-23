terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.62.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.102.0"
    }
  }
}

provider "tfe" {}

provider "hcp" {
  project_id = var.hcp_project_id
}
