resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.name}-devsecops-code"
  acl    = "private"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.name}-test-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.name}-codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:*",
        "codecommit:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_codecommit_repository" "devsecops" {
  repository_name = "${var.name}-devsecops-repo"
  default_branch = "main"
  description     = "This is the Sample App Repository for AWS DevSecOps Workshop"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.name}-devsecops-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

  }

  stage {
    name = "Source"

    action {
      name     = "Source"
      category = "Source"
      owner    = "AWS"
      provider = "CodeCommit"
      version  = "1"
      output_artifacts = [
      "source_output"]

      configuration = {
        BranchName = aws_codecommit_repository.devsecops.default_branch
        RepositoryName = aws_codecommit_repository.devsecops.repository_name
      }
    }
  }

  stage {
    name = "Report"

    action {
      name     = "Report"
      category = "Test"
      owner    = "AWS"
      provider = "CodeBuild"
      input_artifacts = [
        "source_output"]
      output_artifacts =[
      "static_output"]
      version = "1"
      configuration = {
        ProjectName = "devsecops-${var.name}-codebuild-STATIC"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      input_artifacts = [
      "source_output"]
      version = "1"

      configuration = {
        ProjectName = "devsecops-${var.name}-codebuild-BUILD"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name     = "Deploy"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      input_artifacts = [
        "source_output"]
      version = "1"

      configuration = {
        ProjectName = "devsecops-${var.name}-codebuild-DEPLOY"
      }
    }
  }
}