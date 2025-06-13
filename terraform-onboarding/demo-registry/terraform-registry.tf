provider "aws" {
  region                  = "ap-southeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  version                 = ">=2.0"
}

module "ec2_cluster" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "my-cluster"
  instance_count         = 1

  ami                    = "ami-0cd31be676780afa7"
  instance_type          = "t3.micro"
  key_name               = "tf-20200805"
  #monitoring             = true
  vpc_security_group_ids = ["sg-5dee7129"]
  subnet_id              = "subnet-15fb794c"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}