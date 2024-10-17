# Create Private Route Tables
resource "aws_route_table" "openlab_rtb_private1" {
  vpc_id = aws_vpc.openlab_vpc.id

  tags = {
    Name = "openlab-rtb-private1-ap-southeast-2a"
  }
}

resource "aws_route_table" "openlab_rtb_private2" {
  vpc_id = aws_vpc.openlab_vpc.id

  tags = {
    Name = "openlab-rtb-private2-ap-southeast-2b"
  }
}

# Attach Internet Gateway to VPC
resource "aws_route_table" "openlab_rtb_public" {
  vpc_id = aws_vpc.openlab_vpc.id

  #   route {
  #     cidr_block = "0.0.0.0/0"
  #     gateway_id = aws_internet_gateway.openlab_igw.id
  #   }

  tags = {
    Name = "openlab-rtb-public"
  }
}
