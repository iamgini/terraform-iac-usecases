# ================ AAP All-in-One Node =========================
resource "aws_instance" "aapaio" {
  ami             = var.ami
  subnet_id       = var.subnet_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = var.vpc_security_group_ids

  associate_public_ip_address = true

  root_block_device {
    volume_size = 200        # Size in GB for all-in-one setup
    volume_type = "gp3"
  }

  tags = {
    Name    = "aapaio"
    Purpose = "AAP All-in-One Node"
  }
}

# Elastic IP for AAP All-in-One
resource "aws_eip" "aapaio_eip" {
  domain = "vpc"

  tags = {
    Name = "aapaio-eip"
  }
}

# Associate Elastic IP with AAP All-in-One
resource "aws_eip_association" "aapaio_eip_assoc" {
  instance_id   = aws_instance.aapaio.id
  allocation_id = aws_eip.aapaio_eip.id
}
