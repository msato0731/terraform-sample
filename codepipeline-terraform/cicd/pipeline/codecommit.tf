resource "aws_codecommit_repository" "this" {
  repository_name = local.name_prefix
  description     = "Terraform sample repository"
}