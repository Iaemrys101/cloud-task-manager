locals {
  cluster_name   = "${var.project_name}-${var.environment}-cluster"
  service_name   = "${var.project_name}-${var.environment}-backend"
  container_name = "backend"
}

resource "aws_ecs_cluster" "main" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = local.cluster_name
  }
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${local.service_name}"
  retention_in_days = 7

  tags = {
    Name = "${local.service_name}-logs"
  }
}

resource "aws_ecs_task_definition" "backend" {
  family                   = local.service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.task_cpu)
  memory                   = tostring(var.task_memory)
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name                   = local.container_name
      image                  = var.container_image
      essential              = true
      readonlyRootFilesystem = true
      stopTimeout            = 30

      portMappings = [
        {
          name          = "http"
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      environment = [
        {
          name  = "APP_ENV"
          value = var.environment
        }
      ]

      linuxParameters = {
        initProcessEnabled = true
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = local.container_name
          mode                  = "blocking"
        }
      }
    }
  ])

  depends_on = [aws_iam_role_policy_attachment.execution]

  tags = {
    Name = local.service_name
  }
}
