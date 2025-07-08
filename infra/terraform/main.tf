resource "aws_ecs_cluster" "main" {
  name = "deployment-demo-cluster"
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_task_execution_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "ghcr.io/koumi15cancer/deployment_demo/nginx:latest"
      essential = true
      portMappings = [{ containerPort = 80, protocol = "tcp" }]
      environment = []
    }
  ])
}

resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_service_sg_id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.backend_v1.arn
    container_name   = "nginx"
    container_port   = 80
  }
  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_task_definition" "backend_v1" {
  family                   = "backend-v1"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name      = "backend-v1"
      image     = "ghcr.io/koumi15cancer/deployment_demo/backend-v1:latest"
      essential = true
      portMappings = [{ containerPort = 8080, protocol = "tcp" }]
      environment = [
        { name = "SERVICE_NAME", value = "backend-v1" },
        { name = "SERVICE_VERSION", value = "1.0" }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "backend_v2" {
  family                   = "backend-v2"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name      = "backend-v2"
      image     = "ghcr.io/koumi15cancer/deployment_demo/backend-v2:latest"
      essential = true
      portMappings = [{ containerPort = 8080, protocol = "tcp" }]
      environment = [
        { name = "SERVICE_NAME", value = "backend-v2" },
        { name = "SERVICE_VERSION", value = "2.0" }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "backend_shadow" {
  family                   = "backend-shadow"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name      = "backend-shadow"
      image     = "ghcr.io/koumi15cancer/deployment_demo/backend-shadow:latest"
      essential = true
      portMappings = [{ containerPort = 8080, protocol = "tcp" }]
      environment = [
        { name = "SERVICE_NAME", value = "backend-shadow" },
        { name = "SHADOW_MODE", value = "true" }
      ]
    }
  ])
}

resource "aws_ecs_service" "backend_v1" {
  name            = "backend-v1"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend_v1.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_service_sg_id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.backend_v1.arn
    container_name   = "backend-v1"
    container_port   = 8080
  }
  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_service" "backend_v2" {
  name            = "backend-v2"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend_v2.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_service_sg_id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.backend_v2.arn
    container_name   = "backend-v2"
    container_port   = 8080
  }
  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_service" "backend_shadow" {
  name            = "backend-shadow"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend_shadow.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_service_sg_id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.backend_shadow.arn
    container_name   = "backend-shadow"
    container_port   = 8080
  }
  depends_on = [aws_lb_listener.http]
}
