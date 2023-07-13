provider "aws" {}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "this" {
  vpc_id = aws_vpc.this.id
  name   = "example-3"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = aws_vpc.this.cidr_block
  security_group_id = aws_security_group.this.id
  tags = {
    Name = "Hello World"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = aws_vpc.this.cidr_block
  security_group_id = aws_security_group.this.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.this.id
}
