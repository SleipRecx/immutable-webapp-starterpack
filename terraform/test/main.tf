provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-1"
}


resource "aws_s3_bucket" "b1" {
  bucket = "my-s3-tf-test-bucket-1"
  acl    = "private"

  tags = {
    Name        = "My bucket 1"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "b2" {
  bucket = "my-s3-tf-test-bucket-2"
  acl    = "private"

  tags = {
    Name        = "My bucket 2"
    Environment = "Dev"
  }
}


resource "aws_s3_bucket_policy" "b1" {
  bucket = "${aws_s3_bucket.b1.id}"
  policy = templatefile("policy/public_bucket.json.tpl", { bucket_arn = aws_s3_bucket.b1.arn })
}


resource "aws_s3_bucket_policy" "b2" {
  bucket = "${aws_s3_bucket.b2.id}"
  policy = templatefile("policy/public_bucket.json.tpl", { bucket_arn = aws_s3_bucket.b2.arn })
}
