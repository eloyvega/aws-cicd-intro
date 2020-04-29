locals {
  ci_testing_name = "${var.app_name}-testing"
}

resource "aws_codebuild_project" "ci_testing" {
  name          = local.ci_testing_name
  description   = "Run unit tests"
  build_timeout = "15"
  service_role  = aws_iam_role.ci_testing_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:4.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/${var.github_user}/${var.github_repo}.git"
    git_clone_depth = 1
    buildspec       = "config/buildspec_unittests.yml"
  }
}

resource "aws_codebuild_webhook" "ci_testing_webhook" {
  project_name = aws_codebuild_project.ci_testing.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_CREATED,PULL_REQUEST_UPDATED"
    }
  }
}


resource "aws_iam_role" "ci_testing_role" {
  name = "codebuild-${var.app_name}-testing"

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

resource "aws_iam_role_policy" "ci_testing_base_policy" {
  role = aws_iam_role.ci_testing_role.name

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:*:*:log-group:/aws/codebuild/${local.ci_testing_name}",
                "arn:aws:logs:*:*:log-group:/aws/codebuild/${local.ci_testing_name}:*"
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
                "arn:aws:codebuild:*:*:report-group/${local.ci_testing_name}-*"
            ]
        }
    ]
}
POLICY
}