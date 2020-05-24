resource "aws_iam_role" "main" {
  name        = "eks-${var.cluster_name}"
  description = "Role for eks service"
  path        = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "allow-eks-asg" {
  name = "eks-${var.cluster_name}-allow-eks-asg"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "autoscaling:DescribeAutoScalingGroups",
              "autoscaling:DescribeAutoScalingInstances",
              "autoscaling:DescribeLaunchConfigurations",
              "autoscaling:SetDesiredCapacity",
              "autoscaling:TerminateInstanceInAutoScalingGroup",
              "autoscaling:DescribeTags",
              "ec2:DescribeLaunchTemplateVersions"
          ],
          "Resource": "*"
      }
  ]
}
EOF
}

