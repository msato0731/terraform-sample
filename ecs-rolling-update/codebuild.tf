resource "aws_codebuild_project" "sample_app" {
  name         = local.name_prefix
  service_role = aws_iam_role.codebuild.arn

  source {
    type                = "CODEPIPELINE"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    buildspec           = file("./file/buildspec.yml")
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:4.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "REPOSITORY_URI"
      value = aws_ecr_repository.httpd.repository_url
    }
  }
  artifacts {
    type                = "CODEPIPELINE"
    encryption_disabled = false
    name                = local.name_prefix
    packaging           = "NONE"
  }
}
