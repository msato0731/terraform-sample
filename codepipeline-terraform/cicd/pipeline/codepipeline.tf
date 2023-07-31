resource "aws_codepipeline" "this" {
  name     = local.name_prefix
  role_arn = aws_iam_role.codepipeline.arn
  artifact_store {
    location = aws_s3_bucket.codepipeline_artifact.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = aws_codecommit_repository.this.repository_name
        BranchName     = "main"
      }
    }
  }

  stage {
    name = "Plan"

    action {
      name             = "Plan"
      category         = "Test"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["plan_output"]

      configuration = {
        ProjectName = aws_codebuild_project.plan.id
      }
    }
  }
  stage {
    name = "Approval"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        CustomData = "Planの内容を確認の上、問題なければ承認をお願いします。"
      }
    }
  }
  stage {
    name = "Apply"

    action {
      name             = "Apply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["plan_output"]
      output_artifacts = ["apply_output"]

      configuration = {
        ProjectName = aws_codebuild_project.apply.id
      }
    }
  }
}
