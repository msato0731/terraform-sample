terraform {
  required_version = ">= 1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.19.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "aws_ou_id" {
  description = "The id of the OU to deploy the IAM role to"
  type        = string
}

variable "slack_webhook_url" {
  description = "The Slack webhook URL for notifications"
  type        = string
  sensitive   = true
}

resource "aws_cloudformation_stack_set" "this" {
  name             = "ServiceQuotaMonitoring"
  permission_model = "SERVICE_MANAGED"

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  parameters = {
    SlackWebhookUrl = var.slack_webhook_url
  }
  template_body = file("${path.module}/files/service-quota-monitoring.yaml")
  capabilities  = ["CAPABILITY_NAMED_IAM"]
}

resource "aws_cloudformation_stack_set_instance" "this" {
  stack_set_name = aws_cloudformation_stack_set.this.name
  deployment_targets {
    organizational_unit_ids = [var.aws_ou_id]
  }
}
