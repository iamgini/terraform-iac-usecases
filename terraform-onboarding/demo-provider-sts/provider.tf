provider "aws" {
  region = "ap-southeast-1"
  assume_role {
    role_arn     = "YOUR_ROLE_ARN"
    session_name = "sts-arn-demo"
  }
}