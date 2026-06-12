# Create Route in Public Route Table
resource "aws_route" "openlab_public_route" {
  route_table_id         = aws_route_table.openlab_rtb_public.id # Reference the Route Table ID
  destination_cidr_block = "0.0.0.0/0"                           # Specify the destination CIDR block
  gateway_id             = aws_internet_gateway.openlab_igw.id   # Reference the Internet Gateway ID
}

# Create Routes in Private Route Tables to NAT Gateway (both use same NAT GW for cost optimization)
resource "aws_route" "private_route_az1" {
  route_table_id         = aws_route_table.openlab_rtb_private1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route" "private_route_az2" {
  route_table_id         = aws_route_table.openlab_rtb_private2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}
