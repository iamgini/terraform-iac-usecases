## ================================ Ansible Node Instances ================================
resource "aws_instance" "aap-nodes" {
  ami             = var.ami
  subnet_id       = var.subnet_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  count           = var.node_count
  security_groups = var.vpc_security_group_ids
  associate_public_ip_address = true
  # user_data       = file("user-data-ansible-nodes.sh")
  tags = {
    Name = "aap-node-${count.index + 1}"
  }
}
