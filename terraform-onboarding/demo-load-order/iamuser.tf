resource "aws_iam_user" "lb" {
  name = var.iam_user
  path = "/system/"
}