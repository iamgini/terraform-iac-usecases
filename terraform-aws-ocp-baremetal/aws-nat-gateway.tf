# EIP for NAT Gateway
# This is the single public IP used by all private subnet instances for outbound internet
resource "aws_eip" "nat_gw_eip" {
  domain = "vpc"

  tags = {
    Name = "openlab-nat-gw-eip"
  }

  depends_on = [aws_internet_gateway.openlab_igw]
}

# NAT Gateway — placed in a public subnet
# Masters and workers in private subnets use this for outbound internet (quay.io, registry.redhat.io)
resource "aws_nat_gateway" "openlab_nat_gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.openlab_subnet_public1.id

  tags = {
    Name = "openlab-nat-gw"
  }

  depends_on = [aws_internet_gateway.openlab_igw]
}
