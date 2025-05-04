# Create key pair using local ssh key
resource "aws_key_pair" "ec2loginkey" {
  key_name = "tbly-key"
  ## change here if you are using different key pair
  public_key = file(pathexpand(var.ssh_key_pair_pub))
}