terraform {
  backend "s3" {
    bucket = "terraform-remote-demo"
    key    = "remote-terraform-state-demo.tfstate"
    region = "ap-southeast-1"
    dynamodb_table = "tf-state-demo"
  }
}