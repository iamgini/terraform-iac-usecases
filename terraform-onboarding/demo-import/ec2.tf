resource "aws_instance" "myec2" {
  ami                   = "ami-0b1e534a4ff9019e0"
  instance_type         = "t2.micro"
  vpc_security_group_ids = ["sg-5dee7129","sg-061c527def3061da2"]
  key_name              = "tf-20200805"
  subnet_id             = "subnet-3f9f5877"

  tags = {
    Name = "test"
    Env = "Prod"
  }
}
