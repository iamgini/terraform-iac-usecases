# Internet Gateway — attached to VPC for public subnet outbound traffic
resource "aws_internet_gateway" "openlab_igw" {
  vpc_id = aws_vpc.openlab_vpc.id

  tags = {
    Name = "openlab-igw"
  }
}
