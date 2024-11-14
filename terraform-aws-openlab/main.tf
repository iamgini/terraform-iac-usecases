provider "aws" {
  region = "ap-southeast-2"
  ## if you want to mention the aws credential from different path, enable below line
  # shared_credentials_file = "$HOME/.aws/credentials"
  # profile = "openlab"
  #version                 = ">=2.0"
}

# Comment the below one if not required
module "aap" {
  source = "./aap"

  subnet_id  = aws_subnet.openlab_subnet_public1.id
  ami = var.aws_ami_id
  key_name        = aws_key_pair.ec2loginkey.key_name
  vpc_security_group_ids = [aws_security_group.local_access.id]
}
