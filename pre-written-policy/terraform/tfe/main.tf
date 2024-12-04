terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.60.1"
    }
  }
}

provider "tfe" {}

data "tfe_project" "this" {
  name         = var.project_name
  organization = var.organization_name
}

resource "tfe_workspace" "this" {
  name              = "pre-written-policy-test-vpc"
  organization      = var.organization_name
  project_id        = data.tfe_project.this.id
  working_directory = "pre-written-policy/terraform/aws"

  vcs_repo {
    identifier                 = var.vcs_repo_identifier
    branch                     = "main"
    github_app_installation_id = var.github_app_installation_id
  }
}

resource "tfe_policy_set" "this" {
  name          = "pre-written-policy-vpc"
  organization  = var.organization_name
  kind          = "sentinel"
  policies_path = "pre-written-policy/policy"
  workspace_ids = [tfe_workspace.this.id]

  vcs_repo {
    identifier                 = var.vcs_repo_identifier
    branch                     = "main"
    github_app_installation_id = var.github_app_installation_id
  }
}
