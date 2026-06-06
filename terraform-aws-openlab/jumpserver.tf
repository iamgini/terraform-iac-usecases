# ================ Jumpserver/Bastion Host =========================

# Data source for Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance for Jumpserver
resource "aws_instance" "jumpserver" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  subnet_id              = aws_subnet.openlab_subnet_public1.id
  instance_type          = var.jumpserver_instance_type
  key_name               = aws_key_pair.ec2loginkey.key_name
  vpc_security_group_ids = [aws_security_group.jumpserver_sg.id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y ansible-core git wget curl vim

              # Install additional tools for AAP installation
              yum install -y python3-pip
              pip3 install ansible-builder ansible-navigator

              # Create ansible user
              useradd -m -s /bin/bash ansible
              echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ansible

              # Configure SSH for ansible user
              mkdir -p /home/ansible/.ssh
              chmod 700 /home/ansible/.ssh
              chown -R ansible:ansible /home/ansible/.ssh
              EOF

  tags = {
    Name    = "jumpserver"
    Purpose = "Bastion Host for AAP Installation"
  }
}

# Elastic IP for Jumpserver
resource "aws_eip" "jumpserver_eip" {
  domain = "vpc"

  lifecycle {
    prevent_destroy = true  # Keep EIP even on terraform destroy
  }

  tags = {
    Name = "jumpserver-eip"
  }
}

# Associate Elastic IP with Jumpserver
resource "aws_eip_association" "jumpserver_eip_assoc" {
  instance_id   = aws_instance.jumpserver.id
  allocation_id = aws_eip.jumpserver_eip.id
}

# Security Group for Jumpserver
resource "aws_security_group" "jumpserver_sg" {
  vpc_id      = aws_vpc.openlab_vpc.id
  name        = "jumpserver-sg"
  description = "Security group for jumpserver/bastion host"

  # SSH access from anywhere (you may want to restrict this to your IP)
  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP for Let's Encrypt challenge and nginx
  ingress {
    description = "HTTP Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS for nginx reverse proxy
  ingress {
    description = "HTTPS Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP (Ping)
  ingress {
    description = "Allow Ping (ICMP)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
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
    Name = "jumpserver-sg"
  }
}

# Update AAP nodes security group to allow SSH from jumpserver
resource "aws_security_group_rule" "aap_ssh_from_jumpserver" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.local_access.id
  source_security_group_id = aws_security_group.jumpserver_sg.id
  description              = "SSH access from jumpserver"
}
