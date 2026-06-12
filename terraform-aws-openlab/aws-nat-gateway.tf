# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "openlab-nat-eip"
  }
}

# Create single NAT Gateway in Public Subnet AZ1 (cost optimization for lab)
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.openlab_subnet_public1.id

  tags = {
    Name = "openlab-nat-gw"
  }

  # To ensure proper ordering, add an explicit dependency on the Internet Gateway
  depends_on = [aws_internet_gateway.openlab_igw]
}
