terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Configure the GitHub Provider
provider "github" {
  # token = var.token # or `GITHUB_TOKEN`
}

locals {
  repo_names = ["example", "sample", "test"]
}

module "repo" {
  for_each  = toset(local.repo_names)
  source    = "./modules/repo"
  repo_name = each.value
}
