terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.62.0"
    }
  }
}

provider "tfe" {}

data "tfe_project" "this" {
  name         = var.project_name
  organization = var.organization_name
}

data "tfe_github_app_installation" "this" {
  name = var.github_organization_name
}

resource "tfe_workspace" "this" {
  name              = "test-vcs-workspace"
  organization      = var.organization_name
  project_id        = data.tfe_project.this.id
  working_directory = var.terraform_working_directory

  vcs_repo {
    identifier                 = "${var.github_organization_name}/${var.github_repo_name}"
    branch                     = "main"
    github_app_installation_id = data.tfe_github_app_installation.this.id
  }
}
