provider "aws" {
  region = "ap-southeast-2"
}

# app nodes
module "app" {
  source                 = "./app"
  subnet_id              = aws_subnet.tbly_subnet_public1.id
  ami                    = var.aws_ami_id
  key_name               = aws_key_pair.ec2loginkey.key_name
  vpc_security_group_ids = [aws_security_group.local_access.id]
  app_node_count         = 3
}
