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


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.b_assets.bucket_regional_domain_name}"
    origin_id   = "${aws_s3_bucket.b_assets.id}"
  }
  
  origin {
    domain_name = "${aws_s3_bucket.b_config.bucket_regional_domain_name}"
    origin_id   = "${aws_s3_bucket.b_config.id}"
  }

  enabled = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.b_config.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"

  }
  
  ordered_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    path_pattern     = "/assets/*"
    target_origin_id = "${aws_s3_bucket.b_assets.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
  }
}
