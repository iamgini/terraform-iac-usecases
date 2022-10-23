provider "aws" {
  region                  = "ap-southeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  version                 = ">=2.0"
}
resource "aws_iam_user" "lb" {
  name = "iamuser.${count.index}"
  count = 3
  path = "/system/"
}

output "arn-single" {
  value = aws_iam_user.lb[0].arn
}

output "arns" {
  value = aws_iam_user.lb[*].arn
}