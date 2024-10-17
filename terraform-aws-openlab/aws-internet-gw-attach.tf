# # Attach Internet Gateway to VPC
# resource "aws_internet_gateway_attachment" "openlab_igw_attachment" {
#   vpc_id              = aws_vpc.openlab_vpc.id  # Replace with your VPC ID if necessary
#   internet_gateway_id = aws_internet_gateway.openlab_igw.id
# }
