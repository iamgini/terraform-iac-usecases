# Public Subnets
# Bootstrap and bastion go here — they need direct internet access via IGW
# Note: MapPublicIpOnLaunch is FALSE — assign EIPs explicitly where needed
resource "aws_subnet" "openlab_subnet_public1" {
  vpc_id                  = aws_vpc.openlab_vpc.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "openlab-subnet-public1-ap-southeast-1a"
  }
}

resource "aws_subnet" "openlab_subnet_public2" {
  vpc_id                  = aws_vpc.openlab_vpc.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "openlab-subnet-public2-ap-southeast-1b"
  }
}

# Private Subnets
# Masters and workers go here — outbound internet via NAT Gateway, no public IPs
resource "aws_subnet" "openlab_subnet_private1" {
  vpc_id            = aws_vpc.openlab_vpc.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "openlab-subnet-private1-ap-southeast-1a"
  }
}

resource "aws_subnet" "openlab_subnet_private2" {
  vpc_id            = aws_vpc.openlab_vpc.id
  cidr_block        = "10.0.144.0/20"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "openlab-subnet-private2-ap-southeast-1b"
  }
}
