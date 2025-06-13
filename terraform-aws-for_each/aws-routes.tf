# # Create Route in Route Table
resource "aws_route" "tbly_public_route" {
  route_table_id         = aws_route_table.tbly_rtb_public.id # Reference the Route Table ID
  destination_cidr_block = "0.0.0.0/0"                        # Specify the destination CIDR block
  gateway_id             = aws_internet_gateway.tbly_igw.id   # Reference the Internet Gateway ID
}
