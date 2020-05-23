terraform {
  backend "s3" {
    bucket = "austin-devsecops"
    path    = "austin-devsecops/terraform_state"
    region = "us-west-2"
  }
}