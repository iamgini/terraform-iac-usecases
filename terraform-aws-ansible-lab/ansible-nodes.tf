## ================================ Ansible Node Instances ================================
resource "aws_instance" "ansible-nodes" {
  ami                    = var.aws_ami_id #"ami-0cd31be676780afa7"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ec2loginkey.key_name
  count                  = var.ansible_node_count
  subnet_id              = aws_subnet.ansible_lab_subnet_public1.id
  vpc_security_group_ids = [aws_security_group.ansible_access.id]
  user_data              = file("user-data-ansible-nodes.sh")
  tags = {
    Name = "ansible-node-${count.index + 1}"
  }
}
