# Create Subnets
resource "aws_subnet" "ansible_lab_subnet_public1" {
  vpc_id            = aws_vpc.ansible_lab_vpc.id
  cidr_block        = "10.1.0.0/20"
  availability_zone = "ap-southeast-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "ansible-lab-subnet-public1-ap-southeast-1a"
  }
}

resource "aws_subnet" "ansible_lab_subnet_public2" {
  vpc_id            = aws_vpc.ansible_lab_vpc.id
  cidr_block        = "10.1.16.0/20"
  availability_zone = "ap-southeast-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "ansible-lab-subnet-public2-ap-southeast-1b"
  }
}

resource "aws_subnet" "ansible_lab_subnet_private1" {
  vpc_id            = aws_vpc.ansible_lab_vpc.id
  cidr_block        = "10.1.128.0/20"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "ansible-lab-subnet-private1-ap-southeast-1a"
  }
}

resource "aws_subnet" "ansible_lab_subnet_private2" {
  vpc_id            = aws_vpc.ansible_lab_vpc.id
  cidr_block        = "10.1.144.0/20"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "ansible-lab-subnet-private2-ap-southeast-1b"
  }
}
