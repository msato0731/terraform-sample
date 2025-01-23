data "tfe_github_app_installation" "this" {
  name = var.gh_organization_name
}

#### Team ####

resource "tfe_team" "this" {
  organization = var.hcp_tf_organization_name
  name         = var.hcp_tf_team_name
}

resource "time_rotating" "this" {
  rotation_days = 30
}

resource "tfe_team_token" "this" {
  team_id    = tfe_team.this.id
  expired_at = time_rotating.this.rotation_rfc3339
}

#### Project ####

resource "tfe_project" "this" {
  organization = var.hcp_tf_organization_name
  name         = var.hcp_tf_project_name
}

resource "tfe_team_project_access" "this" {
  access     = "custom"
  project_id = tfe_project.this.id
  team_id    = tfe_team.this.id
  project_access {
    settings = "read"
    teams    = "none"
  }
  workspace_access {
    create         = true
    delete         = true
    locking        = false
    move           = false
    run_tasks      = false
    runs           = "apply"
    sentinel_mocks = "none"
    state_versions = "read-outputs"
    variables      = "write"
  }
}

#### Variables Set ####

resource "tfe_variable_set" "this" {
  name         = var.hcp_tf_variables_set_name
  organization = var.hcp_tf_organization_name
  # global       = true # 公式tutorialではGlobal設定
}

# Global -> Projectへの変更の検証
resource "tfe_project_variable_set" "this" {
  variable_set_id = tfe_variable_set.this.id
  project_id      = tfe_project.this.id
}

resource "tfe_variable" "destination_org" {
  key             = "destination_org"
  value           = var.gh_organization_name
  category        = "terraform"
  variable_set_id = tfe_variable_set.this.id
}

# github token手動作成(repo,delete_repo権限付与)
resource "tfe_variable" "gh_token" {
  key             = "gh_token"
  value           = var.gh_token
  category        = "terraform"
  variable_set_id = tfe_variable_set.this.id
  sensitive       = true
}

resource "tfe_variable" "slack_hook_url" {
  key             = "slack_hook_url"
  value           = var.slack_hook_url
  category        = "terraform"
  variable_set_id = tfe_variable_set.this.id
  sensitive       = true
}

resource "tfe_variable" "template_org" {
  key             = "template_org"
  value           = "hashicorp-education"
  category        = "terraform"
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_variable" "template_repo" {
  key             = "template_repo"
  value           = "learn-hcp-waypoint-static-app-template"
  category        = "terraform"
  variable_set_id = tfe_variable_set.this.id
}
resource "tfe_variable" "domain" {
  key             = "domain"
  value           = var.aws_route53_domain
  category        = "terraform"
  variable_set_id = tfe_variable_set.this.id
}
resource "tfe_variable" "route53_zone_id" {
  key             = "route53_zone_id"
  value           = var.aws_route53_zone_id
  category        = "terraform"
  variable_set_id = tfe_variable_set.this.id
}
resource "tfe_variable" "aws_region" {
  key             = "aws_region"
  value           = var.aws_region
  category        = "terraform"
  variable_set_id = tfe_variable_set.this.id
}
resource "tfe_variable" "aws_provider_auth" {
  key             = "TFC_AWS_PROVIDER_AUTH"
  value           = "true"
  category        = "env"
  variable_set_id = tfe_variable_set.this.id
}
resource "tfe_variable" "aws_run_role_arn" {
  key             = "TFC_AWS_RUN_ROLE_ARN"
  value           = var.hcp_tf_aws_run_role_arn
  category        = "env"
  variable_set_id = tfe_variable_set.this.id
}

#### Module Registry ####

resource "tfe_registry_module" "static_app" {
  organization = var.hcp_tf_organization_name
  vcs_repo {
    display_identifier         = "${var.gh_organization_name}/terraform-github-static-app"
    identifier                 = "${var.gh_organization_name}/terraform-github-static-app"
    github_app_installation_id = data.tfe_github_app_installation.this.id
  }
}

resource "tfe_no_code_module" "static_app" {
  organization    = var.hcp_tf_organization_name
  registry_module = tfe_registry_module.static_app.id
}

resource "tfe_registry_module" "route53_subdomain" {
  organization = var.hcp_tf_organization_name
  vcs_repo {
    display_identifier         = "${var.gh_organization_name}/terraform-aws-route53-subdomain"
    identifier                 = "${var.gh_organization_name}/terraform-aws-route53-subdomain"
    github_app_installation_id = data.tfe_github_app_installation.this.id
  }
}

resource "tfe_no_code_module" "route53_subdomain" {
  organization    = var.hcp_tf_organization_name
  registry_module = tfe_registry_module.route53_subdomain.id
}
