provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16" # Replace with your desired CIDR block

  tags = {
    Name = "pre-written-policy-test-vpc"
  }
}
