provider "aws" {
  region     = "ap-southeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  version = ">=2.0"
}

resource "aws_eip" "lb" {
  vpc = true
}

resource "aws_s3_bucket" "mys3" {
  bucket = "demo-onboarding-20200903"
}

output "eip" {
  value = aws_eip.lb.public_ip
}

output "mys3bucket" {
  value = aws_s3_bucket.mys3.bucket_domain_name
}

