provider "aws" {
  region                  = "ap-southeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  version                 = ">=2.0"
}

resource "aws_instance" "web" {
  ami               = "ami-0cd31be676780afa7"
  instance_type     = "t2.micro"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "MultiDiskInstance"
  }
}

resource "aws_ebs_volume" "datadisk1" {
  availability_zone = "ap-southeast-1a"
  size              = 10

  tags = {
    Name = "DataDisk"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.datadisk1.id
  instance_id = aws_instance.web.id
}