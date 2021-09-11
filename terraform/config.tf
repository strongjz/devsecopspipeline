terraform {
  backend "s3" {
    bucket = "devsecops-james-strong"
    key    = "devsecops-james-strong/terraform_state"
    region = "us-west-2"
  }
}
