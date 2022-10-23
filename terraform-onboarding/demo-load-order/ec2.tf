resource "aws_instance" "prod" {
  ami           = "ami-0cd31be676780afa7"
  instance_type = "t2.micro"
}