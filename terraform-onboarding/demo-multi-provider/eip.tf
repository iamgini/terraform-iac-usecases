# this will create in ap-southeast-1
resource "aws_eip" "myeip" {
  vpc = "true"
}

# this will create in ap-south-1
resource "aws_eip" "myeip01" {
  vpc      = "true"
  provider = aws.aws02
}

# this will create in ap-south-1 with devops profile
resource "aws_eip" "myeip02" {
  vpc      = "true"
  provider = aws.aws03
}