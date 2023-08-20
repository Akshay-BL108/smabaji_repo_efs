resource "aws_lb" "jenkins_alb" {
  name               = format("%v-%v-jenkins-alb", var.project, var.environment)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jenkins_alb.id]
  subnets            = var.public_subnets

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.alb_logs_bucket.bucket
    prefix  = "jenkins-alb"
    enabled = true
  }
}

resource "aws_lb_listener" "alb_port80" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "alb_port443" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  //certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "HEALTHY"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "forward_to_8080" {
  listener_arn = aws_lb_listener.alb_port443.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg_8080.arn
  }

  condition {
    host_header {
      values = [var.jenkins_domain_name]
    }
  }
}


resource "aws_lb_target_group" "alb_tg_8080" {
  name        = format("%v-%v-jenkins-alb-8080-tg", var.project, var.environment)
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
  health_check {
    path                = "/login"
    port                = 8080
    protocol            = "HTTP"
    matcher             = "200"
    interval            = "30"
    timeout             = "5"
    unhealthy_threshold = "2"
    healthy_threshold   = "5"
  }
  tags = {
    Name      = format("%v-%v-jenkins-alb-8080-tg", var.project, var.environment)
    CreatedBy = data.aws_caller_identity.current.arn
  }
}
