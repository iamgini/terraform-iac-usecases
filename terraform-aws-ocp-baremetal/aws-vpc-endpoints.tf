# S3 Gateway VPC Endpoint
# Allows private subnet instances to access S3 without going through NAT Gateway
# Useful for AAP Hub RWX storage and any S3 operations from masters/workers
resource "aws_vpc_endpoint" "openlab_s3_vpce" {
  vpc_id            = aws_vpc.openlab_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.openlab_rtb_private1.id,
    aws_route_table.openlab_rtb_private2.id,
    aws_route_table.openlab_rtb_public.id,
  ]

  tags = {
    Name = "openlab-vpce-s3"
  }
}
