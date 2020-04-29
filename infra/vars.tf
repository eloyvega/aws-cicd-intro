variable "region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "cicd-in-aws"
}

variable "github_user" {}
variable "github_repo" {}

variable "github_branch" {
  default = "master"
}