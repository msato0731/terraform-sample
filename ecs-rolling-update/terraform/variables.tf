data "aws_caller_identity" "current" {}

locals {
  name_prefix = "ecs-rolling-update"
}
