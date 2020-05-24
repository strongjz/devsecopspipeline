resource "aws_s3_bucket" "codebuild_s3" {
  bucket = "devsecops-austin-codebuild"
  acl    = "private"
}

resource "aws_iam_role" "devsecops-austin-codebuild" {
    name = "devsecops-austin-codebuild"

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
  role       = aws_iam_role.devsecops-austin-codebuild.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.devsecops-austin-codebuild.name
}


resource "aws_iam_role_policy" "devsecops-austin-codebuild" {
  role = aws_iam_role.devsecops-austin-codebuild.name

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
        "sts:AssumeRole"
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
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "devsecops-austin-codebuild" {
  name          = "devsecops-austin-codebuild"
  description   = "devsecops-austin-codebuild"
  build_timeout = "5"
  service_role  = aws_iam_role.devsecops-austin-codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.codebuild_s3.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ACCOUNT_ID"
      value = "ACCOUNT_ID"
      type  = "PARAMETER_STORE"
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
    type = "CODEPIPELINE"
    buildspec = file("${path.module}/../buildspec.yml")
  }

  source_version = "master"

  tags = {
    Environment = "devsecops-austin"
  }
}

resource "aws_cloudwatch_log_group" "codebuild" {
  name = "devsecops-austin-codebuild"

}

resource "aws_cloudwatch_log_stream" "codebuild" {
  name = "devsecops-austin-codebuild"
  log_group_name = aws_cloudwatch_log_group.codebuild.name
}