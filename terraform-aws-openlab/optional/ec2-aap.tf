## ================================ Ansible Node Instances ================================
resource "aws_instance" "aap-nodes" {
  ami             = var.aws_ami_id
  subnet_id       = aws_subnet.openlab_subnet_public1.id # Specify the subnet ID
  instance_type   = "t2.xlarge"
  key_name        = aws_key_pair.ec2loginkey.key_name
  count           = var.ansible_node_count
  security_groups = [aws_security_group.local_access.id]
  associate_public_ip_address = true
  # user_data       = file("user-data-ansible-nodes.sh")
  tags = {
    Name = "aap-node-${count.index + 1}"
  }
}
