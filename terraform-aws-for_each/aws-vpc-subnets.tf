# Create Subnets
resource "aws_subnet" "tbly_subnet_public1" {
  vpc_id            = aws_vpc.tbly_vpc.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "tbly-subnet-public1-ap-southeast-2a"
  }
}

resource "aws_subnet" "tbly_subnet_public2" {
  vpc_id            = aws_vpc.tbly_vpc.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "tbly-subnet-public2-ap-southeast-2b"
  }
}

resource "aws_subnet" "tbly_subnet_private1" {
  vpc_id            = aws_vpc.tbly_vpc.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "tbly-subnet-private1-ap-southeast-2a"
  }
}

resource "aws_subnet" "tbly_subnet_private2" {
  vpc_id            = aws_vpc.tbly_vpc.id
  cidr_block        = "10.0.144.0/20"
  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "tbly-subnet-private2-ap-southeast-2b"
  }
}