# Prodider Block

provider "aws" {
  region  = var.region
  profile = var.profile
}

resource "aws_key_pair" "ec2loginkey" {
  key_name = "ec2loginkey"
  ## change here if you are using different key pair
  public_key = file(pathexpand(var.ssh_key_pair_pub))
}