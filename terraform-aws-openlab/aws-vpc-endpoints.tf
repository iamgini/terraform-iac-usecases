# Create S3 VPC Endpoint
resource "aws_vpc_endpoint" "openlab_s3_vpce" {
  vpc_id            = aws_vpc.openlab_vpc.id
  service_name      = "com.amazonaws.ap-southeast-2.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "openlab-vpce-s3"
  }
}