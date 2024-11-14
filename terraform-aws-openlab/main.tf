provider "aws" {
  region = "ap-southeast-2"
  ## if you want to mention the aws credential from different path, enable below line
  # shared_credentials_file = "$HOME/.aws/credentials"
  # profile = "openlab"
  #version                 = ">=2.0"
}


module "aap" {
  source = "./aap"

  subnet_id  = aws_subnet.openlab_subnet_public1.id
  ami = var.aws_ami_id
  key_name        = aws_key_pair.ec2loginkey.key_name
  vpc_security_group_ids = [aws_security_group.local_access.id]
}

# resource "aws_key_pair" "ec2loginkey" {
#   key_name = "login-key"
#   ## change here if you are using different key pair
#   public_key = file(pathexpand(var.ssh_key_pair_pub))
# }

# output "ansible-engine" {
#   value = aws_instance.ansible-engine.public_ip
# }

# output "ansible-node-1" {
#   value = aws_instance.ansible-nodes[0].public_ip
# }

# output "ansible-node-2" {
#   value = aws_instance.ansible-nodes[1].public_ip
# }
