# Create Internet Gateway
resource "aws_internet_gateway" "openlab_igw" {
  vpc_id = aws_vpc.openlab_vpc.id

  tags = {
    Name = "openlab-igw"
  }
}
