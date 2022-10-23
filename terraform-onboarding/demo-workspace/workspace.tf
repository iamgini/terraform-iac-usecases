provider "aws" {
  region     = "ap-southeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  version = ">=2.0"
}

resource "aws_instance" "myec2" {
  ami           = "ami-0cd31be676780afa7"
  instance_type = lookup(var.instance_type,terraform.workspace, "t2.micro")
}

variable "instance_type" {
 type = map

 default = {
   default = "t2.nano"
   stage = "t2.nano"
   dev = "t2.micro"
   prod = "t2.large"
 }
}