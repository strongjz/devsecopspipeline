terraform {
  backend "s3" {
    bucket = "austin-devsecops"
    key    = "austin-devsecops/terraform_state"
    region = "us-west-2"
  }
}