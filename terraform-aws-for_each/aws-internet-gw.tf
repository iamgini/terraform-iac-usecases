# Create Internet Gateway
resource "aws_internet_gateway" "tbly_igw" {
  vpc_id = aws_vpc.tbly_vpc.id

  tags = {
    Name = "tbly-igw"
  }
}
