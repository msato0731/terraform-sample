resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "sample_app" {
  name        = local.name_prefix
  cluster     = aws_ecs_cluster.this.arn
  launch_type = "FARGATE"
  # CodePipelineでデプロイ時にリビジョンが更新されるため、最新のrevisionをdataで取得
  task_definition  = data.aws_ecs_task_definition.sample_app.arn
  desired_count    = 1
  platform_version = "1.4.0"

  network_configuration {
    assign_public_ip = false
    security_groups  = [module.ecs_sg.security_group_id]
    subnets          = module.vpc.private_subnets
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.sample_app.arn
    container_name   = "httpd"
    container_port   = 80
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_task_definition" "sample_app" {
  family                   = local.name_prefix
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = templatefile("./file/container_definitions.json", {
    ecr_repository_url : aws_ecr_repository.httpd.repository_url,
  })
  execution_role_arn = aws_iam_role.ecs_tasks.arn
}

data "aws_ecs_task_definition" "sample_app" {
  task_definition = aws_ecs_task_definition.sample_app.family
}
