variable "aws_ami_id" {
  ## Amazon Linux 2 AMI (HVM)
  #default = "ami-02f26adf094f51167"

  ## Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
  default = "ami-055d15d9cfddf7bd3"
  ## "ami-0cd31be676780afa7"
}

variable "ssh_key_pair" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_key_pair_pub" {
  default = "~/.ssh/id_rsa.pub"
}

variable "node_count" {
  default = 2
}
