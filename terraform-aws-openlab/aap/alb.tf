# ================ Application Load Balancer for AAP Nodes =========================

# Application Load Balancer
resource "aws_lb" "aap_alb" {
  name               = "aap-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.vpc_security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = false
  enable_http2              = true

  tags = {
    Name = "aap-alb"
    Purpose = "AAP Load Balancer"
  }
}

# Target Group for Controller (port 8443)
resource "aws_lb_target_group" "aap_controller" {
  name     = "aap-controller-tg"
  port     = 8443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/api/v2/ping/"
    protocol            = "HTTPS"
    matcher             = "200"
  }

  tags = {
    Name = "aap-controller-tg"
  }
}

# Target Group for Hub (port 8444)
resource "aws_lb_target_group" "aap_hub" {
  name     = "aap-hub-tg"
  port     = 8444
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/api/galaxy/"
    protocol            = "HTTPS"
    matcher             = "200"
  }

  tags = {
    Name = "aap-hub-tg"
  }
}

# Target Group for EDA (port 8445)
resource "aws_lb_target_group" "aap_eda" {
  name     = "aap-eda-tg"
  port     = 8445
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "HTTPS"
    matcher             = "200,302"
  }

  tags = {
    Name = "aap-eda-tg"
  }
}

# Target Group for Gateway (port 8446)
resource "aws_lb_target_group" "aap_gateway" {
  name     = "aap-gateway-tg"
  port     = 8446
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "HTTPS"
    matcher             = "200,302"
  }

  tags = {
    Name = "aap-gateway-tg"
  }
}

# Listener for HTTPS (443) - only created if SSL certificate is provided
resource "aws_lb_listener" "aap_https" {
  count             = var.ssl_certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.aap_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aap_gateway.arn
  }
}

# Listener for HTTP (80) - redirect to HTTPS if SSL cert provided, otherwise forward
resource "aws_lb_listener" "aap_http" {
  load_balancer_arn = aws_lb.aap_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = var.ssl_certificate_arn != "" ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.ssl_certificate_arn != "" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    target_group_arn = var.ssl_certificate_arn == "" ? aws_lb_target_group.aap_gateway.arn : null
  }
}

# Listener Rules for path-based routing (only if HTTPS listener exists)
resource "aws_lb_listener_rule" "controller_rule" {
  count        = var.ssl_certificate_arn != "" ? 1 : 0
  listener_arn = aws_lb_listener.aap_https[0].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aap_controller.arn
  }

  condition {
    path_pattern {
      values = ["/controller/*", "/api/controller/*"]
    }
  }
}

resource "aws_lb_listener_rule" "hub_rule" {
  count        = var.ssl_certificate_arn != "" ? 1 : 0
  listener_arn = aws_lb_listener.aap_https[0].arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aap_hub.arn
  }

  condition {
    path_pattern {
      values = ["/hub/*", "/api/galaxy/*"]
    }
  }
}

resource "aws_lb_listener_rule" "eda_rule" {
  count        = var.ssl_certificate_arn != "" ? 1 : 0
  listener_arn = aws_lb_listener.aap_https[0].arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aap_eda.arn
  }

  condition {
    path_pattern {
      values = ["/eda/*"]
    }
  }
}

# Attach AAP instances to target groups
resource "aws_lb_target_group_attachment" "controller_attachment" {
  count            = var.aap_node_count
  target_group_arn = aws_lb_target_group.aap_controller.arn
  target_id        = aws_instance.aap-nodes[count.index].id
  port             = 8443
}

resource "aws_lb_target_group_attachment" "hub_attachment" {
  count            = var.aap_node_count
  target_group_arn = aws_lb_target_group.aap_hub.arn
  target_id        = aws_instance.aap-nodes[count.index].id
  port             = 8444
}

resource "aws_lb_target_group_attachment" "eda_attachment" {
  count            = var.aap_node_count
  target_group_arn = aws_lb_target_group.aap_eda.arn
  target_id        = aws_instance.aap-nodes[count.index].id
  port             = 8445
}

resource "aws_lb_target_group_attachment" "gateway_attachment" {
  count            = var.aap_node_count
  target_group_arn = aws_lb_target_group.aap_gateway.arn
  target_id        = aws_instance.aap-nodes[count.index].id
  port             = 8446
}
