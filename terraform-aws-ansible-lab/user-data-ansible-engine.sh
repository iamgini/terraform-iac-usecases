#! /bin/bash
# Fedora 43 setup script
sudo useradd devops
echo -e 'devops\ndevops' | sudo passwd devops
echo 'devops ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/devops
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo systemctl restart sshd.service
sudo dnf install -y python3
sudo dnf install -y vim
sudo dnf install -y ansible
sudo dnf install -y git
sudo dnf install -y sshpass
# sudo dnf update -y