terraform {
  required_version = "~> 1.11.2"
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.64.0"
    }
  }
  cloud {}
  # cloud {
  #   organization = ""

  #   workspaces {
  #     name    = ""
  #     project = ""
  #   }
  # }
}

provider "tfe" {
  hostname = "app.terraform.io"
}

data "tfe_oauth_client" "this" {
  organization = var.hcp_tf_organization_name
  name         = var.hcp_tf_oauth_client_name
}

data "tfe_project" "this" {
  name         = var.hcp_tf_project_name
  organization = var.hcp_tf_organization_name
}

resource "tfe_workspace" "this" {
  name         = "test-github-oauth-ec2"
  organization = var.hcp_tf_organization_name
  vcs_repo {
    branch         = "main"
    identifier     = "msato0731/aws-tfc-introductory-book-samples"
    oauth_token_id = data.tfe_oauth_client.this.oauth_token_id
  }
  working_directory = "infra/chapter5/aws/prod"
  project_id        = data.tfe_project.this.id
}
