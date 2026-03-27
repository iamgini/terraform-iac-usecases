# Public Route Table — routes internet traffic via IGW
resource "aws_route_table" "openlab_rtb_public" {
  vpc_id = aws_vpc.openlab_vpc.id

  tags = {
    Name = "openlab-rtb-public"
  }
}

# Private Route Tables — one per AZ, route internet traffic via NAT Gateway
resource "aws_route_table" "openlab_rtb_private1" {
  vpc_id = aws_vpc.openlab_vpc.id

  tags = {
    Name = "openlab-rtb-private1-ap-southeast-1a"
  }
}

resource "aws_route_table" "openlab_rtb_private2" {
  vpc_id = aws_vpc.openlab_vpc.id

  tags = {
    Name = "openlab-rtb-private2-ap-southeast-1b"
  }
}
