resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.prefix}-app"
  retention_in_days = 7
}

# ALB の 5xx エラーを監視するアラーム
# Bake Time 中にこのアラームが発火すると自動ロールバックが実行される
resource "aws_cloudwatch_metric_alarm" "ecs_5xx" {
  alarm_name          = "${local.prefix}-alb-5xx"
  alarm_description   = "Triggers rollback if ALB returns too many 5xx errors during bake time"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}
