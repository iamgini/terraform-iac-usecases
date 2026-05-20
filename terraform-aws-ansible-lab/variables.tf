variable "aws_ami_id" {
  ## Fedora 43 Cloud Base AMI
  default = "ami-04d824463ef922362"
  ## Previous: Amazon Linux 2 AMI (HVM) - "ami-02f26adf094f51167"
  ## Previous: RHEL9 - "ami-0cd31be676780afa7"
}

variable "aws_vpc_name" {
  default     = "ansible-lab-vpc"
  description = "Name of the VPC for Ansible Lab"
}

variable "ssh_key_pair" {
  default = "~/.ssh/id_rsa"
  #default = "~/.ssh/id_rsa_ansilble_lab"
}

variable "ssh_key_pair_pub" {
  default = "~/.ssh/id_rsa.pub"
  #default = "~/.ssh/id_rsa_ansilble_lab.pub"
}

variable "ansible_node_count" {
  default = 2
}

variable "lab_security_group_name" {
  default = "ansible-lab-sg"
}
