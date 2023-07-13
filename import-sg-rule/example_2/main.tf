provider "aws" {}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "this" {
  vpc_id = aws_vpc.this.id
  name   = "example-2"
}

resource "aws_security_group_rule" "ingress_allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.this.cidr_block, "10.0.1.0/24"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "ingress_allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.this.cidr_block]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

# resource "aws_ec2_tag" "test" {
#   resource_id = aws_security_group_rule.ingress_allow_http.security_group_rule_id
#   key         = "Name"
#   value       = "Hello World"
# }

# 空になる
output "test" {
  value = aws_security_group_rule.ingress_allow_http.security_group_rule_id
}
