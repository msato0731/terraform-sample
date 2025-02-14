resource "hcp_waypoint_tfc_config" "this" {
  token        = tfe_team_token.this.token
  tfc_org_name = var.hcp_tf_organization_name
}

resource "hcp_waypoint_template" "this" {
  name                            = "static-webapp"
  summary                         = "A template for static webapps"
  terraform_no_code_module_source = "private/${var.hcp_tf_organization_name}/${tfe_registry_module.static_app.name}/github"
  terraform_no_code_module_id     = tfe_no_code_module.static_app.id
  terraform_project_id            = tfe_project.this.id
  description                     = "A static webapp template that creates a GitHub repository with a GitHub Actions workflow that deploys to GitHub Pages."
  labels                          = ["static", "webapp", "javascript"]
  readme_markdown_template = base64encode(
    templatefile(
      "${path.module}/templates/waypoint_readme_static_app.md",
      { github_organization_name = var.gh_organization_name }
    )
  )
}

resource "hcp_waypoint_application" "this" {
  name        = "mywebapp"
  template_id = hcp_waypoint_template.this.id
}

resource "hcp_waypoint_add_on_definition" "this" {
  name                            = "subdomain"
  description                     = "This add-on creates a subdomain for the Waypoint application that points to the GitHub Pages website for that application."
  summary                         = "An add-on for creating subdomains"
  terraform_no_code_module_id     = tfe_no_code_module.route53_subdomain.id
  terraform_no_code_module_source = "private/${var.hcp_tf_organization_name}/${tfe_registry_module.route53_subdomain.name}/aws"
  terraform_project_id            = tfe_project.this.id
  # 本来は不要だが、plan差分が出続けるため追加 hcp provider v0.102時点
  terraform_cloud_workspace_details = {
    name                 = tfe_project.this.name
    terraform_project_id = tfe_project.this.id
  }
  labels = ["subdomain", "route53"]
  readme_markdown_template = base64encode(
    templatefile("${path.module}/templates/waypoint_readme_subdomain.md",
      { github_organization_name = var.gh_organization_name }
    )
  )
  variable_options = [
    {
      name          = "gh_token"
      options       = []
      variable_type = "string"
      user_editable = true
    },
    {
      name          = "route53_zone_id"
      options       = []
      variable_type = "string"
      user_editable = true
    }
  ]
}

resource "hcp_waypoint_add_on" "this" {
  name           = "subdomain"
  definition_id  = hcp_waypoint_add_on_definition.this.id
  application_id = hcp_waypoint_application.this.id
}

resource "hcp_waypoint_action" "this" {
  name        = "Merge Branch"
  description = "Merge the specific branch into the main branch"
  request = {
    custom = {
      method = "POST"
      url    = "https://api.github.com/repos/$${application.outputs.repo_name}/merges"
      body   = file("${path.module}/files/waypoint_action_body.json")
      headers = {
        Accept               = "application/vnd.github+json"
        Authorization        = "Bearer $${var.gh_token}"
        X-GitHub-Api-Version = "2022-11-28"
      }
    }
  }
}

data "hcp_waypoint_application" "this" {
  name = "mywebapp"
}

output "waypoint_app_output" {
  value = data.hcp_waypoint_application.this.output_values
}
