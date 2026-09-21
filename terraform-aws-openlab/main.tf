provider "aws" {
  region = "ap-southeast-2"
  ## if you want to mention the aws credential from different path, enable below line
  # shared_credentials_file = "$HOME/.aws/credentials"
  # profile = "openlab"
  #version                 = ">=2.0"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token != "" ? var.cloudflare_api_token : "dummytoken123456789012345678901234567890"
}

# AAP HA cluster — controlled by var.enable_aap in terraform.tfvars
module "aap" {
  count  = var.enable_aap ? 1 : 0
  source = "./aap"

  subnet_id              = aws_subnet.openlab_subnet_private1.id
  vpc_id                 = aws_vpc.openlab_vpc.id
  ami                    = var.aws_ami_id
  key_name               = aws_key_pair.ec2loginkey.key_name
  vpc_security_group_ids = [aws_security_group.local_access.id]
  aap_node_count         = var.aap_node_count
  enable_public_ip       = var.enable_public_ip_aap
}

# AAP All-in-One — controlled by var.enable_aapaio in terraform.tfvars
module "aapaio" {
  count  = var.enable_aapaio ? 1 : 0
  source = "./aapaio"

  subnet_id              = aws_subnet.openlab_subnet_public1.id
  ami                    = var.aws_ami_id
  key_name               = aws_key_pair.ec2loginkey.key_name
  vpc_security_group_ids = [aws_security_group.local_access.id]
  instance_type          = "c5.4xlarge"
  aapaio_domain_name     = var.aapaio_domain_name
}
