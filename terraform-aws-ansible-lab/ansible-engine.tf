## ================================ Ansible Engine Instance ================================================
resource "aws_instance" "ansible-engine" {
  ami                    = var.aws_ami_id #"ami-0cd31be676780afa7"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ec2loginkey.key_name
  subnet_id              = aws_subnet.ansible_lab_subnet_public1.id
  vpc_security_group_ids = [aws_security_group.ansible_access.id]
  user_data              = file("user-data-ansible-engine.sh")

  # Create inventory and ansible.cfg on ansible-engine
  provisioner "remote-exec" {
    inline = [
      "echo '[ansible]' >> /home/fedora/inventory",
      "echo 'ansible-engine ansible_host=${aws_instance.ansible-engine.private_dns} ansible_connection=local' >> /home/fedora/inventory",
      "echo '[nodes]' >> /home/fedora/inventory",
      "echo 'node1 ansible_host=${aws_instance.ansible-nodes[0].private_dns}' >> /home/fedora/inventory",
      "echo 'node2 ansible_host=${aws_instance.ansible-nodes[1].private_dns}' >> /home/fedora/inventory",
      "echo '' >> /home/fedora/inventory",
      "echo '[all:vars]' >> /home/fedora/inventory",
      "echo 'ansible_user=devops' >> /home/fedora/inventory",
      "echo 'ansible_password=devops' >> /home/fedora/inventory",
      "echo 'ansible_connection=ssh' >> /home/fedora/inventory",
      "echo '#ansible_python_interpreter=/usr/bin/python3' >> /home/fedora/inventory",
      "echo 'ansible_ssh_private_key_file=/home/devops/.ssh/id_rsa' >> /home/fedora/inventory",
      "echo \"ansible_ssh_extra_args=' -o StrictHostKeyChecking=no -o PreferredAuthentications=password '\" >> /home/fedora/inventory",
      "echo '[defaults]' >> /home/fedora/ansible.cfg",
      "echo 'inventory = ./inventory' >> /home/fedora/ansible.cfg",
      "echo 'host_key_checking = False' >> /home/fedora/ansible.cfg",
      "echo 'remote_user = devops' >> /home/fedora/ansible.cfg",
    ]
    connection {
      type        = "ssh"
      user        = "fedora"
      private_key = file(pathexpand(var.ssh_key_pair))
      host        = self.public_ip
      agent       = false
    }
  }

  # copy engine-config.yaml
  provisioner "file" {
    source      = "engine-config.yaml"
    destination = "/home/fedora/engine-config.yaml"
    connection {
      type        = "ssh"
      user        = "fedora"
      private_key = file(pathexpand(var.ssh_key_pair))
      host        = self.public_ip
    }
  }

  # Execute Ansible Playbook
  provisioner "remote-exec" {
    inline = [
      "sleep 180; ansible-playbook engine-config.yaml"
    ]
    connection {
      type        = "ssh"
      user        = "fedora"
      private_key = file(pathexpand(var.ssh_key_pair))
      host        = self.public_ip
    }
  }

  tags = {
    Name = "ansible-engine"
  }
}