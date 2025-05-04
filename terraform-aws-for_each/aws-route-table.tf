# Create Private Route Tables
resource "aws_route_table" "tbly_rtb_private1" {
  vpc_id = aws_vpc.tbly_vpc.id

  tags = {
    Name = "tbly-rtb-private1-ap-southeast-2a"
  }
}

resource "aws_route_table" "tbly_rtb_private2" {
  vpc_id = aws_vpc.tbly_vpc.id

  tags = {
    Name = "tbly-rtb-private2-ap-southeast-2b"
  }
}

# Attach Internet Gateway to VPC
resource "aws_route_table" "tbly_rtb_public" {
  vpc_id = aws_vpc.tbly_vpc.id

  #   route {
  #     cidr_block = "0.0.0.0/0"
  #     gateway_id = aws_internet_gateway.tbly_igw.id
  #   }

  tags = {
    Name = "tbly-rtb-public"
  }
}
