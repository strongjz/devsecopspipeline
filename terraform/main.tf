resource "aws_ecr_repository" "golang_example" {
  name                 = "golang_example"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    env = "devsecops"
  }
}


