# Public route — all internet traffic via IGW
# Required for bootstrap node (which has an EIP) to reach quay.io
resource "aws_route" "openlab_public_route" {
  route_table_id         = aws_route_table.openlab_rtb_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.openlab_igw.id
}

# Private routes — all internet traffic via NAT Gateway
# Masters and workers use these to pull images from quay.io/registry.redhat.io during install
resource "aws_route" "openlab_private_route1" {
  route_table_id         = aws_route_table.openlab_rtb_private1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.openlab_nat_gw.id
}

resource "aws_route" "openlab_private_route2" {
  route_table_id         = aws_route_table.openlab_rtb_private2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.openlab_nat_gw.id
}
