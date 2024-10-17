# Create Subnets
resource "aws_subnet" "openlab_subnet_public1" {
  vpc_id            = aws_vpc.openlab_vpc.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "openlab-subnet-public1-ap-southeast-2a"
  }
}

resource "aws_subnet" "openlab_subnet_public2" {
  vpc_id            = aws_vpc.openlab_vpc.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "openlab-subnet-public2-ap-southeast-2b"
  }
}

resource "aws_subnet" "openlab_subnet_private1" {
  vpc_id            = aws_vpc.openlab_vpc.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "openlab-subnet-private1-ap-southeast-2a"
  }
}

resource "aws_subnet" "openlab_subnet_private2" {
  vpc_id            = aws_vpc.openlab_vpc.id
  cidr_block        = "10.0.144.0/20"
  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "openlab-subnet-private2-ap-southeast-2b"
  }
}