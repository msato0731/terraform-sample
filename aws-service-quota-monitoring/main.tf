# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# EventBridge Rule for Trusted Advisor
resource "aws_cloudwatch_event_rule" "service_quota_monitoring" {
  name        = "ServiceQuotaMonitoring-Alert"
  description = "Monitor AWS service quotas via Trusted Advisor alerts"

  event_pattern = jsonencode({
    source      = ["aws.trustedadvisor"]
    detail-type = ["Trusted Advisor Check Item Refresh Notification"]
    detail = {
      status = ["ERROR", "WARN"]
      check-name = [
        "VPC",
        "VPC Internet Gateways",
        "EC2-VPC Elastic IP Address",
      ]
    }
  })

  state = "ENABLED"
}

# EventBridge target for Step Functions
resource "aws_cloudwatch_event_target" "step_functions_target" {
  rule      = aws_cloudwatch_event_rule.service_quota_monitoring.name
  target_id = "ServiceQuotaMonitoringStepFunctionsTarget"
  arn       = aws_sfn_state_machine.slack_notification.arn
  role_arn  = aws_iam_role.eventbridge.arn

  input_transformer {
    input_paths = {
      account   = "$.account"
      checkname = "$.detail.check-name"
      region    = "$.region"
      status    = "$.detail.status"
    }
    input_template = "{\n  \"account\": \"<account>\",\n  \"checkname\": \"<checkname>\",\n  \"region\": \"<region>\",\n  \"status\": \"<status>\"\n}"
  }
}

# EventBridge Connection for HTTP calls
resource "aws_cloudwatch_event_connection" "slack_webhook" {
  name        = "ServiceQuotaMonitoring-SlackWebhook"
  description = "Connection for Slack webhook"

  authorization_type = "API_KEY"
  auth_parameters {
    api_key {
      key   = "Authorization"
      value = "Bearer dummy" # Slack webhooks don't require auth, but connection needs this
    }
  }
}

# Step Functions State Machine
resource "aws_sfn_state_machine" "slack_notification" {
  name     = "ServiceQuotaMonitoring-SlackNotification"
  role_arn = aws_iam_role.step_functions.arn

  definition = templatefile("${path.module}/statemachine/slack-notification.asl.json", {
    slack_webhook_url = var.slack_webhook_url
    connection_arn    = aws_cloudwatch_event_connection.slack_webhook.arn
  })
}

# IAM Role for EventBridge
resource "aws_iam_role" "eventbridge" {
  name = "ServiceQuotaMonitoring-EventBridge-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceArn"     = aws_cloudwatch_event_rule.service_quota_monitoring.arn
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# IAM Policy for EventBridge to invoke Step Functions
resource "aws_iam_role_policy" "eventbridge" {
  name = "ServiceQuotaMonitoring-EventBridge-Policy"
  role = aws_iam_role.eventbridge.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution"
        ]
        Resource = aws_sfn_state_machine.slack_notification.arn
      }
    ]
  })
}

# IAM Role for Step Functions
resource "aws_iam_role" "step_functions" {
  name = "ServiceQuotaMonitoring-StepFunctions-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Step Functions to make HTTP requests
resource "aws_iam_role_policy" "step_functions" {
  name = "ServiceQuotaMonitoring-StepFunctions-Policy"
  role = aws_iam_role.step_functions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "states:InvokeHTTPEndpoint"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "states:HTTPEndpoint" = var.slack_webhook_url
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "events:RetrieveConnectionCredentials"
        ]
        Resource = aws_cloudwatch_event_connection.slack_webhook.arn
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_cloudwatch_event_connection.slack_webhook.secret_arn
      }
    ]
  })
}
