resource "aws_ecs_cluster" "ecs-cluster-poc" {
  name = "ecs-cluster-poc"
}

resource "aws_ecs_service" "ecs-service-poc" {
  name            = "url-shortener-app"
  cluster         = aws_ecs_cluster.ecs-cluster-poc.id
  task_definition = aws_ecs_task_definition.ecs-task-definition-poc.arn
  scheduling_strategy  = "REPLICA"
  launch_type     = "EC2"
  desired_count = 2

  network_configuration {
    subnets          = var.aws_private_subnets
    assign_public_ip = false
    security_groups = var.security_groups
  }

    load_balancer {
    target_group_arn = var.lb_target_arn
    container_name   = "link-shortener-app"
    container_port   = 3000
  }
  depends_on = [var.lb_listener]
}

resource "aws_ecs_task_definition" "ecs-task-definition-poc" {
  family                   = "ecs-task-definition-poc"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = var.iam_role_arn
  task_role_arn            = var.iam_role_arn
  container_definitions    = <<EOF
[
  {
    "name": "link-shortener-app",
    "image": "${var.aws_ecr_image}",
    "memory": 1024,
    "cpu": 512,
    "essential": true,
    "entryPoint": [],
    "portMappings": [
      {
        "containerPort": 3000
      }
    ]
  }
]
EOF
}