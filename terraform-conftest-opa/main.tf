resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.instance_name}-vpc"
    Environment = "dev"
    Owner       = "sato.masaki"
  }
}

resource "aws_security_group" "web" {
  name_prefix = "${var.instance_name}-sg-"
  description = "Security group for ${var.instance_name}"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from office"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.instance_name}-sg"
    Environment = "dev"
    Owner       = "sato.masaki"
  }
}

resource "aws_ebs_volume" "data" {
  availability_zone = "ap-northeast-1a"
  size              = 10
  encrypted         = true

  tags = {
    Name        = "${var.instance_name}-vol"
    Environment = "dev"
    Owner       = "sato.masaki"
  }
}
