provider "tfe" {
  hostname = "app.terraform.io"
}

resource "tfe_organization" "main" {
  name  = "my-org-name"
  email = "admin@company.com"
}

resource "tfe_workspace" "test" {
  name         = "test-workspace"
  organization = tfe_organization.main.name
}

resource "tfe_variable" "aws_instance_type" {
  key          = "instance_type"
  value        = "t3.micro"
  category     = "terraform"
  workspace_id = tfe_workspace.test.id
}