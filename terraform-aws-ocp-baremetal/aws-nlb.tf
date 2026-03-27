# ============================================================
# External (internet-facing) API NLB
# Handles: api.<cluster>.<domain>
# Targets: Bootstrap + Masters on 6443 and 22623
# ============================================================
resource "aws_lb" "ocp_api_external" {
  name               = "ocp-api"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.openlab_subnet_public1.id, aws_subnet.openlab_subnet_public2.id]

  enable_deletion_protection = false

  tags = {
    Name = "ocp-api"
  }
}

# Target Group — port 6443 (Kubernetes API)
resource "aws_lb_target_group" "ocp_api_6443" {
  name        = "ocp-api"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = aws_vpc.openlab_vpc.id
  target_type = "instance"

  health_check {
    protocol            = "HTTPS"
    path                = "/readyz"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  tags = {
    Name = "ocp-api"
  }
}

# Target Group — port 22623 (Machine Config Server)
resource "aws_lb_target_group" "ocp_api_22623" {
  name        = "ocp-api-int"
  port        = 22623
  protocol    = "TCP"
  vpc_id      = aws_vpc.openlab_vpc.id
  target_type = "instance"

  health_check {
    protocol            = "HTTPS"
    path                = "/readyz"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  tags = {
    Name = "ocp-api-int"
  }
}

# Listeners for external API NLB
resource "aws_lb_listener" "ocp_api_external_6443" {
  load_balancer_arn = aws_lb.ocp_api_external.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ocp_api_6443.arn
  }
}

resource "aws_lb_listener" "ocp_api_external_22623" {
  load_balancer_arn = aws_lb.ocp_api_external.arn
  port              = 22623
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ocp_api_22623.arn
  }
}


# ============================================================
# Internal API NLB
# Handles: api-int.<cluster>.<domain>
# CRITICAL: Must be internal so masters/workers (no public IP)
# can reach the Machine Config Server via private IPs
# Targets: Bootstrap + Masters on 6443 and 22623
# ============================================================
resource "aws_lb" "ocp_api_internal" {
  name               = "ocp-api-internal"
  internal           = true
  load_balancer_type = "network"
  # Internal NLB goes in private subnets
  subnets            = [aws_subnet.openlab_subnet_private1.id, aws_subnet.openlab_subnet_private2.id]

  enable_deletion_protection = false

  tags = {
    Name = "ocp-api-internal"
  }
}

# Target Group — internal 6443
resource "aws_lb_target_group" "ocp_api_int_6443" {
  name        = "ocp-api-int-6443"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = aws_vpc.openlab_vpc.id
  target_type = "instance"

  health_check {
    protocol            = "HTTPS"
    path                = "/readyz"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  tags = {
    Name = "ocp-api-int-6443"
  }
}

# Target Group — internal 22623
resource "aws_lb_target_group" "ocp_api_int_22623" {
  name        = "ocp-api-int-22623"
  port        = 22623
  protocol    = "TCP"
  vpc_id      = aws_vpc.openlab_vpc.id
  target_type = "instance"

  health_check {
    protocol            = "HTTPS"
    path                = "/readyz"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  tags = {
    Name = "ocp-api-int-22623"
  }
}

# Listeners for internal API NLB
resource "aws_lb_listener" "ocp_api_internal_6443" {
  load_balancer_arn = aws_lb.ocp_api_internal.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ocp_api_int_6443.arn
  }
}

resource "aws_lb_listener" "ocp_api_internal_22623" {
  load_balancer_arn = aws_lb.ocp_api_internal.arn
  port              = 22623
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ocp_api_int_22623.arn
  }
}


# ============================================================
# Application Ingress NLB
# Handles: *.apps.<cluster>.<domain>
# Targets: Worker nodes on 443 and 80
# ============================================================
resource "aws_lb" "ocp_app_ingress" {
  name               = "ocp-app-ingress"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.openlab_subnet_public1.id, aws_subnet.openlab_subnet_public2.id]

  enable_deletion_protection = false

  tags = {
    Name = "ocp-app-ingress"
  }
}

# Target Group — port 443 (HTTPS app traffic)
# Health check on port 1936 — Ingress Controller publishes health stats there
resource "aws_lb_target_group" "ocp_app_ingress_443" {
  name        = "ocp-app-ingress"
  port        = 443
  protocol    = "TCP"
  vpc_id      = aws_vpc.openlab_vpc.id
  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    path                = "/healthz/ready"
    port                = "1936"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  tags = {
    Name = "ocp-app-ingress"
  }
}

# Target Group — port 80 (HTTP app traffic)
resource "aws_lb_target_group" "ocp_app_ingress_80" {
  name        = "ocp-app-ingress-http"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.openlab_vpc.id
  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    path                = "/healthz/ready"
    port                = "1936"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  tags = {
    Name = "ocp-app-ingress-http"
  }
}

# Listeners for ingress NLB
resource "aws_lb_listener" "ocp_app_ingress_443" {
  load_balancer_arn = aws_lb.ocp_app_ingress.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ocp_app_ingress_443.arn
  }
}

resource "aws_lb_listener" "ocp_app_ingress_80" {
  load_balancer_arn = aws_lb.ocp_app_ingress.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ocp_app_ingress_80.arn
  }
}
