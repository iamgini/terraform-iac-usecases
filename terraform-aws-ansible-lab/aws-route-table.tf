# Create Private Route Tables
resource "aws_route_table" "ansible_lab_rtb_private1" {
  vpc_id = aws_vpc.ansible_lab_vpc.id

  tags = {
    Name = "ansible-lab-rtb-private1-ap-southeast-1a"
  }
}

resource "aws_route_table" "ansible_lab_rtb_private2" {
  vpc_id = aws_vpc.ansible_lab_vpc.id

  tags = {
    Name = "ansible-lab-rtb-private2-ap-southeast-1b"
  }
}

# Create Public Route Table
resource "aws_route_table" "ansible_lab_rtb_public" {
  vpc_id = aws_vpc.ansible_lab_vpc.id

  tags = {
    Name = "ansible-lab-rtb-public"
  }
}
