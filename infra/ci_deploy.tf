locals {
  ci_deploy_name = "${var.app_name}-deploy"
}

resource "aws_codebuild_project" "ci_deploy" {
  name          = local.ci_deploy_name
  description   = "Deploy static website"
  build_timeout = "15"
  service_role  = aws_iam_role.ci_deploy_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:4.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "WEBSITE_BUCKET"
      value = "placeholder"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "config/buildspec_deploy.yml"
  }
}


resource "aws_iam_role" "ci_deploy_role" {
  name = "codebuild-${var.app_name}-deploy"

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

resource "aws_iam_role_policy" "ci_deploy_base_policy" {
  role = aws_iam_role.ci_deploy_role.name

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:*:*:log-group:/aws/codebuild/${local.ci_deploy_name}",
                "arn:aws:logs:*:*:log-group:/aws/codebuild/${local.ci_deploy_name}:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases"
            ],
            "Resource": [
                "arn:aws:codebuild:*:*:report-group/${local.ci_deploy_name}-*"
            ]
        }
    ]
}
POLICY
}