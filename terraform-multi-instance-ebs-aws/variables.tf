variable "region" {
  default = "ap-southeast-1"
}
variable "tier" {
  default = "test"

}
variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  default = "ami-02f26adf094f51167" #"ami-0b0af3577fe5e3532"  
}

variable "root_size" {
  default = 10

}
variable "vpc_zone_identifier" {
  default = ["subnet-ddc15182", "subnet-d80f9bbe", "subnet-a2a43683"]

}

variable "ex_vpc" {
  default = "vpc-25349458"
}

variable "profile" {
  default = "ansible"
}

variable "ec2_keypair" {
  default = "forall"
}

variable "ssh_key_pair" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_key_pair_pub" {
  default = "~/.ssh/id_rsa.pub"
}

variable "azs" {
  type    = list(any)
  default = ["us-east-1b", "us-east-1a", "us-east-1c"]
  #default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "device_name" {
  default = "/dev/xvdf"
}

/*
variable "azs" {
	type = map
	default = {
		0 = "us-east-1a"
		1 = "us-east-1b"
		2 = "us-east-1c"
	}
}
*/

