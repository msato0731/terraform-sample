resource "aws_security_group" "ecs_tasks" {
  name        = "${local.prefix}-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-tasks-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_tasks_http" {
  security_group_id = aws_security_group.ecs_tasks.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "ecs_tasks_all" {
  security_group_id = aws_security_group.ecs_tasks.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
