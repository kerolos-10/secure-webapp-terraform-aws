
resource "aws_lb" "public" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false
  idle_timeout               = 60

  tags = var.tags
}

resource "aws_lb_target_group" "public_tg" {
  name        = var.target_group_name
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path     = "/"
    protocol = "HTTP"
    matcher  = "200"
  }

  tags = var.tags
}

resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = aws_lb.public.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "public_targets" {
  count            = length(var.target_instance_ids)
  target_group_arn = aws_lb_target_group.public_tg.arn
  target_id        = var.target_instance_ids[count.index]
  port             = var.target_port
}
