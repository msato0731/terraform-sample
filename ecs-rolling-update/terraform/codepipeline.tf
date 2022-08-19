resource "aws_codepipeline" "sample_app" {
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
      version          = 1
      output_artifacts = ["source_output"]
      configuration = {
        RepositoryName       = aws_codecommit_repository.sample_app.repository_name
        BranchName           = "main"
        OutputArtifactFormat = "CODE_ZIP"
        PollForSourceChanges = "false"
      }
    }
  }
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.sample_app.id
      }
    }
  }
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = 1
      input_artifacts = ["build_output"]
      configuration = {
        ClusterName = aws_ecs_cluster.this.id
        ServiceName = aws_ecs_service.sample_app.name
      }
    }
  }
}

resource "aws_cloudwatch_event_rule" "codepipeline_sample_app" {
  name = "${local.name_prefix}-codepipeline-sample-app"

  event_pattern = templatefile("./file/codepipeline_event_pattern.json", {
    codecommit_arn : aws_codecommit_repository.sample_app.arn
  })
}

resource "aws_cloudwatch_event_target" "codepipeline_sample_app" {
  rule     = aws_cloudwatch_event_rule.codepipeline_sample_app.name
  arn      = aws_codepipeline.sample_app.arn
  role_arn = aws_iam_role.event_bridge_codepipeline.arn
}
