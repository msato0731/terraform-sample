
###############################################################################
# CodePipeline
###############################################################################

resource "aws_iam_role" "codepipeline" {
  name               = "${local.name_prefix}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
  inline_policy {
    name   = "codepipeline"
    policy = file("./file/iam_policy/codepipeline.json")
  }
}

data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

###############################################################################
# CodeBuild
###############################################################################

resource "aws_iam_role" "codebuild" {
  name               = "${local.name_prefix}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  inline_policy {
    name = "codebuild"
    policy = templatefile("./file/iam_policy/codebuild.json",
      {
        codepipeline_artifact_bucket : aws_s3_bucket.codepipeline_artifact.arn
      }
    )
  }
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

###############################################################################
# ECS Task Exec Role
###############################################################################

resource "aws_iam_role" "ecs_tasks" {
  name               = "${local.name_prefix}-ecs-tasks-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks.json
  inline_policy {
    name   = "ecs-tasks"
    policy = file("./file/iam_policy/ecs-tasks.json")
  }
}

data "aws_iam_policy_document" "ecs_tasks" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

###############################################################################
# EventBridge
###############################################################################
resource "aws_iam_role" "event_bridge_codepipeline" {
  name               = "${local.name_prefix}-event-bridge-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.event_bridge_assume_role.json
  inline_policy {
    name   = "codepipeline"
    policy = data.aws_iam_policy_document.event_bridge_codepipeline.json
  }
}

data "aws_iam_policy_document" "event_bridge_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "event_bridge_codepipeline" {
  statement {
    actions   = ["codepipeline:StartPipelineExecution"]
    resources = ["${aws_codepipeline.sample_app.arn}"]
  }
}
