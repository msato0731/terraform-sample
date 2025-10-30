variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  sensitive   = true
}