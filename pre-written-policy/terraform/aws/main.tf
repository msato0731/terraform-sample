provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16" # Replace with your desired CIDR block

  tags = {
    Name = "pre-written-policy-test"
  }
}

# VPC Flow Log関連設定

# resource "aws_flow_log" "this" {
#   iam_role_arn    = aws_iam_role.flow_log.arn
#   log_destination = aws_cloudwatch_log_group.flow_log.arn
#   traffic_type    = "REJECT"
#   vpc_id          = aws_vpc.this.id
# }

# resource "aws_cloudwatch_log_group" "flow_log" {
#   name = "pre-written-policy-test-flow-log"
# }

# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["vpc-flow-logs.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "flow_log" {
#   name               = "pre-written-policy-test-flow-log"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# data "aws_iam_policy_document" "flow_log" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams",
#     ]

#     resources = ["*"]
#   }
# }

# resource "aws_iam_role_policy" "cwlogs" {
#   name   = "cwlogs"
#   role   = aws_iam_role.flow_log.id
#   policy = data.aws_iam_policy_document.flow_log.json
# }
