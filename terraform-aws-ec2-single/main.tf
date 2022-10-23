provider "aws" {
  region = "ap-southeast-1"
  ## if you want to mention the aws credential from different path, enable below line
  #shared_credentials_file = "$HOME/.aws/credentials"
  profile = "devops"
  #version                 = ">=2.0"
}

resource "aws_key_pair" "ec2loginkey" {
  key_name = "ec2-login-key"
  ## change here if you are using different key pair
  public_key = file(pathexpand(var.ssh_key_pair_pub))
}

output "demo-ec2-output" {
  value = aws_instance.demo-ec2.public_ip
}
