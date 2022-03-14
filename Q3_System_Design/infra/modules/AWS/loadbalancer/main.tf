resource "aws_alb" "application_load_balancer" {
  name               = "url-shortener-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.aws_public_subnets
  security_groups    = var.security_groups
}

resource "aws_lb_target_group" "target_group" {
  name        = "url-shortener-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id = var.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }
}