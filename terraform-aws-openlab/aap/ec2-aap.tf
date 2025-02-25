# ================ AAP Nodes =========================
resource "aws_instance" "aap-nodes" {
  ami             = var.ami
  subnet_id       = var.subnet_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  count           = var.aap_node_count
  security_groups = var.vpc_security_group_ids
  associate_public_ip_address = true

  root_block_device {
    volume_size = 100        # Size in GB
    volume_type = "gp3"      # General Purpose SSD (adjust if necessary)
  }

  # user_data       = file("user-data-ansible-nodes.sh")

  tags = {
    Name = var.aap_node_names[count.index]
  }

}
