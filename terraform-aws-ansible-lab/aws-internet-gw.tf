# Create Internet Gateway
resource "aws_internet_gateway" "ansible_lab_igw" {
  vpc_id = aws_vpc.ansible_lab_vpc.id

  tags = {
    Name = "ansible-lab-igw"
  }
}
