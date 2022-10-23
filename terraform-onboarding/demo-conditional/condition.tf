provider "aws" {
  region     = "ap-southeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  version = ">=2.0"
}

variable "testorprod" {}

resource "aws_instance" "prod" {
  ami           = "ami-0cd31be676780afa7"
  instance_type = "t2.micro"
  # if var.testorprod is false, then create 1 instance, else 0 instance
  count = var.testorprod == false ? 2 : 0
}

resource "aws_instance" "dev" {
  ami           = "ami-0cd31be676780afa7"
  instance_type = "t2.large"
  # if var.testorprod is true, then create 1 instance, else 0 instance
  count = var.testorprod == true ? 1 : 0
}