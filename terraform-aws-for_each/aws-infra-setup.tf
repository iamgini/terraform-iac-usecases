
# # Enable DNS Hostnames
# resource "aws_vpc_attribute" "tbly_vpc_dns" {
#   vpc_id                = aws_vpc.tbly_vpc.id
#   enable_dns_hostnames  = true
# }

# # Create VPC Endpoint for S3
# resource "aws_vpc_endpoint" "tbly_s3_vpce" {
#   vpc_id       = aws_vpc.tbly_vpc.id
#   service_name = "com.amazonaws.ap-southeast-2.s3"

#   tags = {
#     Name = "tbly-vpce-s3"
#   }
# }


# Modify VPC Endpoint to add Private Route Tables
resource "aws_vpc_endpoint_route_table_association" "private_rtb_assoc_1" {
  vpc_endpoint_id = aws_vpc_endpoint.tbly_s3_vpce.id
  route_table_id  = aws_route_table.tbly_rtb_private1.id
}

resource "aws_vpc_endpoint_route_table_association" "private_rtb_assoc_2" {
  vpc_endpoint_id = aws_vpc_endpoint.tbly_s3_vpce.id
  route_table_id  = aws_route_table.tbly_rtb_private2.id
}
