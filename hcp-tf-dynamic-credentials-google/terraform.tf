terraform {
  required_version = ">= 1.13.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.10.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.70.0"
    }
  }
}
