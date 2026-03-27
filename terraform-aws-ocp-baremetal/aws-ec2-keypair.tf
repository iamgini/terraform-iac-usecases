# SSH Key Pair for EC2 instances
resource "aws_key_pair" "ec2loginkey" {
  key_name   = "openlab-key"
  public_key = file(pathexpand(var.ssh_key_pair_pub))
}
