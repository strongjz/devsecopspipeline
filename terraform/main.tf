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

//for signing it needs to be asymmetrical
//https://docs.aws.amazon.com/kms/latest/developerguide/symm-asymm-choose.html
resource "aws_kms_key" "cosign" {
  description             = "Cosign Key"
  deletion_window_in_days = 10
  tags = {
    env = var.name
  }
  key_usage = "SIGN_VERIFY"
  customer_master_key_spec = "RSA_4096"
}

resource "aws_kms_alias" "cosign" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.cosign.key_id
}
