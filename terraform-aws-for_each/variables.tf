variable "aws_ami_id" {
  ## Amazon Linux 2 AMI (HVM)
  default = "ami-02f26adf094f51167"
  ## "ami-0cd31be676780afa7"
}

variable "aws_vpc_name" {
  default     = "tbly_vpc"
  description = "Name of the VPC"
}

variable "ssh_key_pair" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_key_pair_pub" {
  default = "~/.ssh/id_rsa.pub"
}

variable "ansible_node_count" {
  default = 1
}

variable "lab_security_group_name" {
  default = "tbly-sg"
}

variable "sg_ports_local_access" {
  description = "Security Group ports for local access"
  default = {
    ssh = {
      port        = 22
      description = "SSH Access"
      protocol    = "tcp"
    }

    icmp = {
      port        = -1
      description = "Allow Ping (ICMP)"
      protocol    = "icmp"
    }

    http = {
      port        = 80
      description = "HTTP Access"
      protocol    = "tcp"
    }

    https = {
      port        = 443
      description = "HTTPS Access"
      protocol    = "tcp"
    }

    postgresql = {
      port        = 5432
      description = "PostgreSQL Access"
      protocol    = "tcp"
    }

    receptor = {
      port        = 27199
      description = "Receptor Access"
      protocol    = "tcp"
    }

    redis_default = {
      port        = 6379
      description = "Redis"
      protocol    = "tcp"
    }

    redis_alt = {
      port        = 16379
      description = "Redis"
      protocol    = "tcp"
    }

    grpc = {
      port        = 50051
      description = "gRPC"
      protocol    = "tcp"
    }

    controller_nginx_https = {
      port        = 8443
      description = "controller_nginx_https_port"
      protocol    = "tcp"
    }

    hub_nginx_https = {
      port        = 8444
      description = "hub_nginx_https_port"
      protocol    = "tcp"
    }

    eda_nginx_https = {
      port        = 8445
      description = "eda_nginx_https_port"
      protocol    = "tcp"
    }

    gateway_nginx_https = {
      port        = 8446
      description = "gateway_nginx_https_port"
      protocol    = "tcp"
    }

  }
}
