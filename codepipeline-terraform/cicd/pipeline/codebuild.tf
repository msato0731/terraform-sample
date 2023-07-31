resource "aws_codebuild_project" "plan" {
  name         = "${local.name_prefix}-plan"
  service_role = aws_iam_role.codepipeline.arn
  source {
    type      = "CODEPIPELINE"
    buildspec = "codepipeline-terraform/workload/infra/buildspec_plan.yml"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
    dynamic "environment_variable" {
      for_each = local.codebuild_env_vars
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }
  artifacts {
    type = "CODEPIPELINE"
  }
}

resource "aws_codebuild_project" "apply" {
  name         = "${local.name_prefix}-apply"
  service_role = aws_iam_role.codepipeline.arn
  source {
    type      = "CODEPIPELINE"
    buildspec = "codepipeline-terraform/workload/infra/buildspec_apply.yml"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
    dynamic "environment_variable" {
      for_each = local.codebuild_env_vars
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }
  artifacts {
    type = "CODEPIPELINE"
  }
}
