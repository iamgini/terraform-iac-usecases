# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.tbly_subnet_public1.id
  route_table_id = aws_route_table.tbly_rtb_public.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.tbly_subnet_public2.id
  route_table_id = aws_route_table.tbly_rtb_public.id
}


# Associate Private Subnets with Route Tables
resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.tbly_subnet_private1.id
  route_table_id = aws_route_table.tbly_rtb_private1.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.tbly_subnet_private2.id
  route_table_id = aws_route_table.tbly_rtb_private2.id
}