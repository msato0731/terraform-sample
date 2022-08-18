resource "aws_ecr_registry_scanning_configuration" "this" {
  scan_type = "BASIC"

  rule {
    scan_frequency = "SCAN_ON_PUSH"
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}

resource "aws_ecr_repository" "httpd" {
  name                 = "${local.name_prefix}-httpd"
  image_tag_mutability = "MUTABLE"
  # サンプルのため後で消しやすいように
  force_delete = true
}
