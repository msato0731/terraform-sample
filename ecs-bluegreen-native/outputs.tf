output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "production_url" {
  description = "Production URL (port 80)"
  value       = "http://${aws_lb.main.dns_name}"
}

output "test_url" {
  description = "Test URL (port 8080) - Green revision during deployment"
  value       = "http://${aws_lb.main.dns_name}:8080"
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "cloudwatch_alarm_name" {
  description = "CloudWatch alarm name for rollback testing"
  value       = aws_cloudwatch_metric_alarm.ecs_5xx.alarm_name
}
