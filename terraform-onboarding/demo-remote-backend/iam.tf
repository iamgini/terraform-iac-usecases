terraform {
  required_version = "~> 0.13.0"
  backend "remote" {}
}

resource "aws_iam_user" "lb" {
  name = "remoteuser"
  path = "/system/"
}