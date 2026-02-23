################################################################################
# ECS Task Execution Role
################################################################################

resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.prefix}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

################################################################################
# ECS Infrastructure Role for Load Balancers
# ECS 組み込みブルーグリーンデプロイで ALB リソースを管理するための専用ロール
################################################################################

resource "aws_iam_role" "ecs_infrastructure_lb" {
  name = "${local.prefix}-ecs-infra-lb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAccessToECSForInfrastructureManagement"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_infrastructure_lb" {
  role       = aws_iam_role.ecs_infrastructure_lb.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSInfrastructureRolePolicyForLoadBalancers"
}
