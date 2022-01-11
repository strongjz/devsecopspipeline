terraform {
  backend "s3" {
    bucket = "devsecops-codemash-2022"
    key    = "devsecops-codemash-2022/terraform_state"
    region = "us-west-2"
  }
}
