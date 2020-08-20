resource "aws_ecr_repository" "golang_example" {
  name                 = "golang_example-${var.name}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    env = "devsecops"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_ssm_parameter" "account_id" {
  value = data.aws_caller_identity.current.account_id
  name  = "ACCOUNT_ID"
  type  = "String"
  overwrite = true
}

