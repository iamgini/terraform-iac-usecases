provider "aws" {
  region     = "ap-southeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  version = ">=2.0"
}

resource "aws_security_group" "sgvardemo" {
  name        = "sg-using-vars"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpn_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpn_ip]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.vpn_ip]
  }
}