provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-1"
}


resource "aws_s3_bucket" "b_assets" {
  bucket = "my-s3-tf-test-bucket-1"
  acl    = "private"

  tags = {
    Name        = "My bucket 1"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "b_config" {
  bucket = "my-s3-tf-test-bucket-2"
  acl    = "private"

  tags = {
    Name        = "My bucket 2"
    Environment = "Dev"
  }
}


resource "aws_s3_bucket_policy" "b1" {
  bucket = "${aws_s3_bucket.b_assets.id}"
  policy = templatefile("policy/public_bucket.json.tpl", { bucket_arn = aws_s3_bucket.b_assets.arn })
}


resource "aws_s3_bucket_policy" "b2" {
  bucket = "${aws_s3_bucket.b_config.id}"
  policy = templatefile("policy/public_bucket.json.tpl", { bucket_arn = aws_s3_bucket.b_config.arn })
}


# resource "aws_cloudfront_distribution" "s3_distribution" {
#   origin {
#     domain_name = "${aws_s3_bucket.b1.bucket_regional_domain_name}"
#     origin_id   = "${local.s3_origin_id}"

#     s3_origin_config {
#       origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
#     }
#   }
