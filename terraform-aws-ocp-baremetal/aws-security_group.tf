# ============================================================
# General Lab Security Group (Bastion)
# ============================================================
resource "aws_security_group" "local_access" {
  vpc_id      = aws_vpc.openlab_vpc.id
  name        = var.lab_security_group_name
  description = "General lab access - bastion and management nodes"

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Ping (ICMP)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "bootstrap.ign hosting (Python HTTP server)"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "PostgreSQL Access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Receptor Access"
    from_port   = 27199
    to_port     = 27199
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Redis"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Redis Cluster"
    from_port   = 16379
    to_port     = 16379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "gRPC"
    from_port   = 50051
    to_port     = 50051
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "AAP Controller HTTPS"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "AAP Hub HTTPS"
    from_port   = 8444
    to_port     = 8444
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "AAP EDA HTTPS"
    from_port   = 8445
    to_port     = 8445
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "AAP Gateway HTTPS"
    from_port   = 8446
    to_port     = 8446
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "AAP Dashboard HTTPS"
    from_port   = 8447
    to_port     = 8447
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.lab_security_group_name
  }
}

# ============================================================
# OCP Nodes Security Group (Bootstrap, Masters, Workers)
# ============================================================
# IMPORTANT: Inbound rules for 6443 and 22623 are required for NLB
# health checks to pass. Without these, NLB will mark all targets
# as unhealthy even when the services are running correctly.
resource "aws_security_group" "ocp_sg" {
  vpc_id      = aws_vpc.openlab_vpc.id
  name        = "ocp-sg"
  description = "OCP cluster nodes - bootstrap, masters, workers"

  # Kubernetes API — required for NLB health checks and cluster access
  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Machine Config Server — required for nodes to fetch ignition configs
  ingress {
    description = "Machine Config Server"
    from_port   = 22623
    to_port     = 22623
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH from VPC only — access via bastion
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Bootstrap journal — used during install monitoring
  ingress {
    description = "Bootstrap journal (systemd-journal-gatewayd)"
    from_port   = 19531
    to_port     = 19531
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # VXLAN — OVN-Kubernetes SDN overlay
  ingress {
    description = "VXLAN (OVN)"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Geneve — OVN-Kubernetes tunnel
  ingress {
    description = "Geneve (OVN)"
    from_port   = 6081
    to_port     = 6081
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  # etcd — control plane only
  ingress {
    description = "etcd peer"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Internal cluster communication
  ingress {
    description = "Internal cluster traffic"
    from_port   = 9000
    to_port     = 9999
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "Kubelet"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "NodePort services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow all inbound from within the cluster (pod-to-pod, node-to-node)
  ingress {
    description = "All inbound from VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ocp-sg"
  }
}
