provider "aws" {
  region                  = "ap-southeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  version                 = ">=2.0"
}

data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "app-dev" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t2.micro"
}

/*
output "ami" {
  value = data.aws_ami.app_ami
}
*/