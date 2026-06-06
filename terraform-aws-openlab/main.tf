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

# Comment the below one if not required
module "aap" {
  source = "./aap"

  subnet_id              = aws_subnet.openlab_subnet_public1.id
  subnet_ids             = [aws_subnet.openlab_subnet_public1.id, aws_subnet.openlab_subnet_public2.id]
  vpc_id                 = aws_vpc.openlab_vpc.id
  ami                    = var.aws_ami_id
  key_name               = aws_key_pair.ec2loginkey.key_name
  vpc_security_group_ids = [aws_security_group.local_access.id]
  aap_node_count         = var.aap_node_count
  ssl_certificate_arn    = var.ssl_certificate_arn  # Not using ACM - using Let's Encrypt on Nginx
  enable_public_ip       = var.enable_public_ip_aap
}
