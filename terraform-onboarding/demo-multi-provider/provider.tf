provider "aws" {
  region = "ap-southeast-1"
}

provider "aws" {
  region = "ap-south-1"
  alias  = "aws02"
}

provider "aws" {
  region  = "ap-south-1"
  alias   = "aws03"
  profile = "devops"
}


