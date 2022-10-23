provider "aws" {
  region                  = "ap-southeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  version                 = ">=2.0"
}

resource "aws_instance" "myec2" {
  ami           = "ami-0cd31be676780afa7"
  instance_type = "t2.micro"
  
  provisioner "local-exec" {
    command = "echo ${aws_instance.myec2.private_ip} >> private_ips.txt"
  }
}
