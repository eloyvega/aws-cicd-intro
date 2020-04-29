resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${var.app_name}-artifacts-"
  acl           = "private"
  force_destroy = true
}