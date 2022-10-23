provider "aws" {
  region     = "ap-southeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  version = ">=2.0"
}

locals {
  common_tags = {
    Owner = "Dev Team"
    Service = "Backend"
  }
}

resource "aws_instance" "dev" {
  ami           = "ami-0cd31be676780afa7"
  instance_type = "t2.large"
  tags = local.common_tags
}

resource "aws_ebs_volume" "db_ebs" {
  availability_zone = "us-west-2a"
  size              = 8
  tags = local.common_tags
}