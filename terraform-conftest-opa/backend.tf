terraform {
  backend "s3" {
    bucket       = "<STATE_BUCKET>"
    key          = "terraform-conftest-opa/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}
