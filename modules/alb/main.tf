resource "aws_lb_target_group" "nodegroup" {
  name   = "${var.eks_name}-tg"
  vpc_id = var.vpc_id

  connection_termination            = var.connection_termination
  ip_address_type                   = var.ip_address_type
  load_balancing_cross_zone_enabled = var.load_balancing_cross_zone_enabled
  port                              = var.port
  protocol                          = var.protocol
  protocol_version                  = var.protocol_version
  proxy_protocol_v2                 = var.proxy_protocol_v2
  slow_start                        = var.slow_start
  health_check {
    path                = "/healthz/ready"
    port                = "32639"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
    timeout             = 5
    matcher             = "200"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [health_check]
  }
}

#resource "aws_lb_target_group" "" {}

resource "aws_lb" "eks" {
  name                       = "${var.eks_name}-alb"
  internal                   = var.alb_internal
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.subnet_ids
  drop_invalid_header_fields = true
  enable_deletion_protection = var.alb_delete_protection

  #  access_logs {
  #    bucket  = aws_s3_bucket.lb_logs.id
  #    prefix  = "test-lb"
  #    enabled = true
  #  }

  tags = var.tags
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.eks.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# in case of additional certificates.
#resource "aws_lb_listener_certificate" "eks" {
#  certificate_arn = var.certificate_arn
#  listener_arn    = aws_lb_listener.eks_ingress
#}

# ToDo: update policy and test it
#tfsec:ignore:aws-elb-use-secure-tls-policy
resource "aws_lb_listener" "eks_ingress" {
  load_balancer_arn = aws_lb.eks.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }

  tags = var.tags
}

resource "aws_lb_listener_rule" "istio_tg" {
  listener_arn = aws_lb_listener.eks_ingress.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nodegroup.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  tags = var.tags
}

resource "aws_route53_record" "eks_alb" {
  name    = "*"
  zone_id = var.dns_zone_id
  type    = "A"
  alias {
    name                   = aws_lb.eks.dns_name
    zone_id                = aws_lb.eks.zone_id
    evaluate_target_health = true
  }
}
