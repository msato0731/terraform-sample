# terraform blockをコメントアウトすると、hashicorp/githubが使われます。
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.0"
    }
  }
}

variable "repo_name" {
  description = "The name of the GitHub repository"
  type        = string
  default     = "example"

}

resource "github_repository" "example" {
  name        = var.repo_name
  description = "My awesome codebase"

  visibility = "private"
}
