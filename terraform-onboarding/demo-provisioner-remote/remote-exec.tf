provider "aws" {
  region                  = "ap-southeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  version                 = ">=2.0"
}

resource "aws_instance" "myec2" {
  ami           = "ami-0cd31be676780afa7"
  instance_type = "t2.micro"
  key_name = "tf-20200805"
  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install -y nginx1.12",
      "sudo systemctl start nginx"
    ]
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("/home/devops/.ssh/tf-20200805.pem")
      host = self.public_ip
    }
  }
}
