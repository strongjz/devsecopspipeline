terraform {
  backend "s3" {
    bucket = "contino-devsecops"
    key    = "contino-devsecops/terraform_state"
    region = "us-west-2"
  }
}
