variable "aws_ami_id" {
  ## Amazon Linux 2 AMI (HVM)
  # default = "ami-02f26adf094f51167"

  # RHEL9 AMI in ap-southeast-2
  default = "ami-0705fe1e9a50e0d57"

  ## "ami-0cd31be676780afa7"
}

variable "aws_vpc_name" {
  default     = "openlab_vpc"
  description = "Name of the VPC"
}

variable "ssh_key_pair" {
  default = "~/.ssh/id_rsa"
  #default = "~/.ssh/id_rsa_ansilble_lab"
}

variable "ssh_key_pair_pub" {
  default = "~/.ssh/id_rsa.pub"
  #default = "~/.ssh/id_rsa_ansilble_lab.pub"
}

variable "ocp_node_count" {
  default = 8
}

variable "lab_security_group_name" {
  default = "openlab-sg"
}
