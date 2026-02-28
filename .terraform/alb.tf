resource "aws_lb" "frontend" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_target_group" "frontend" {
  name     = "${var.project_name}-tg-front"
  port     = var.porta_http
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-tg-front"
  }
}

resource "aws_lb_target_group_attachment" "frontend" {
  count            = length(aws_instance.frontend)
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.frontend[count.index].id
  port             = var.porta_http
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = var.porta_http
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}
