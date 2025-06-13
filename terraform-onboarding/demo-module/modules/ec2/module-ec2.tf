resource "aws_instance" "myec2" {
  ami           = "ami-0cd31be676780afa7"
  instance_type = var.instance_type
}
