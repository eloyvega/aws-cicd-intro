resource "aws_s3_bucket" "website_bucket" {
  bucket_prefix = var.app_name
  acl           = "public-read"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = <<EOF
{
  "Version":"2008-10-17",
  "Id":"PolicyForPublicWebsiteContent",
  "Statement":[
    {
      "Sid":"PublicReadGetObject",
      "Effect":"Allow",
      "Principal":{
        "AWS":"*"
      },
      "Action":"s3:GetObject",
      "Resource":"${aws_s3_bucket.website_bucket.arn}/*"
    }
  ]
}
EOF
}

output "website_dns" {
  value = aws_s3_bucket.website_bucket.website_endpoint
}