# Create Route in Public Route Table
resource "aws_route" "ansible_lab_public_route" {
  route_table_id         = aws_route_table.ansible_lab_rtb_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ansible_lab_igw.id
}
