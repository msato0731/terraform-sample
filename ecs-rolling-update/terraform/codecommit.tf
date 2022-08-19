resource "aws_codecommit_repository" "sample_app" {
  repository_name = "${local.name_prefix}-sample-app"
}
