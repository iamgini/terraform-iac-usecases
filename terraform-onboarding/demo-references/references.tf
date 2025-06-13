provider "aws" {
  region     = "ap-southeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  version = ">=2.0"
}

resource "aws_instance" "web" {
  ami           = "ami-0cd31be676780afa7"
  instance_type = "t2.micro"

  tags = {
    Name = "hello"
  }
}

resource "aws_eip" "mylb" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id =  aws_instance.web.id
  allocation_id = aws_eip.mylb.id
}

resource "aws_security_group" "allow_tls" {
  name        = "test-allow_tls"
  description = "Allow TLS inbound traffic"
  #vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_eip.mylb.public_ip}/32"]
  }
  
  tags = {
    Name = "allow_tls"
  }
}