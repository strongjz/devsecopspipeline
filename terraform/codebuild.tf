resource "aws_s3_bucket" "codebuild_s3" {
  bucket = "devsecops-${var.name}-${data.aws_caller_identity.current.account_id}-codebuild"
  acl    = "private"
}

resource "aws_iam_role" "devsecops-codebuild" {
  name = "devsecops-${var.name}-codebuild"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.devsecops-codebuild.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.devsecops-codebuild.name
}


resource "aws_iam_role_policy" "devsecops-codebuild" {
  role = aws_iam_role.devsecops-codebuild.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "sts:AssumeRole",
        "codebuild:*",
        "eks:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs",
        "ecr:*",
        "ssm:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:us-west-2:*:network-interface/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.codebuild_s3.arn}",
        "${aws_s3_bucket.codebuild_s3.arn}/*",
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
        "${aws_kms_key.cosign.arn}"
      ],
      "Action": [
        "kms:*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "devsecops-codebuild-STATIC" {
  name          = "devsecops-${var.name}-codebuild-STATIC"
  description   = "devsecops-${var.name}-codebuild-STATIC"
  build_timeout = "5"
  service_role  = aws_iam_role.devsecops-codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
    artifact_identifier = "static-code-report"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "true"

    environment_variable {
      name  = "ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = aws_cloudwatch_log_stream.codebuild.name
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.codebuild_s3.id}/STATIC-log"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../STATIC-buildspec.yml")
  }

  source_version = "master"

  tags = {
    Environment = "devsecops-${var.name}"
  }
}

resource "aws_codebuild_project" "devsecops-codebuild-BUILD" {
  name          = "devsecops-${var.name}-codebuild-BUILD"
  description   = "devsecops-${var.name}-codebuild-BUILD"
  build_timeout = "5"
  service_role  = aws_iam_role.devsecops-codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "true"

    environment_variable {
      name  = "ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = aws_cloudwatch_log_stream.codebuild.name
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.codebuild_s3.id}/build-log"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../BUILD-buildspec.yml")
  }

  source_version = "master"

  tags = {
    Environment = "devsecops-${var.name}"
  }
}

resource "aws_codebuild_project" "devsecops-codebuild-DEPLOY" {
  name          = "devsecops-${var.name}-codebuild-DEPLOY"
  description   = "devsecops-${var.name}-codebuild-DEPLOY"
  build_timeout = "5"
  service_role  = aws_iam_role.devsecops-codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "true"

    environment_variable {
      name  = "ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = aws_cloudwatch_log_stream.codebuild.name
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.codebuild_s3.id}/deploy-log"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../DEPLOY-buildspec.yml")
  }

  source_version = "master"

  tags = {
    Environment = "devsecops-${var.name}"
  }
}

resource "aws_cloudwatch_log_group" "codebuild" {
  name = "devsecops-${var.name}-codebuild"

}

resource "aws_cloudwatch_log_stream" "codebuild" {
  name           = "devsecops-${var.name}-codebuild"
  log_group_name = aws_cloudwatch_log_group.codebuild.name
}