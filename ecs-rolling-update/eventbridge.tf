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
