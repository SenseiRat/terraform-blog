resource "aws_s3_bucket" "code" {
  bucket_prefix = var.domain_name
  acl           = "private"
  force_destroy = true
  versioning {
    enabled = false
  }

  tags = {
    Name = "code bucket"
  }
}

resource "aws_s3_bucket" "data" {
  bucket_prefix        = var.domain_name
  acl           = "private"
  force_destroy = true
  versioning {
    enabled = false
  }

  tags = {
    Name = "data bucket"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket_prefix = var.domain_name
  acl = "private"
  force_destroy = true
  versioning {
    enabled = false
  }
  lifecycle_rule {
    enabled = true
    tags = {
      Name = "log rotation"
    }
    expiration {
      days = 14
    }
  }

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.logs.arn}",
      "Principal": {
        "AWS": [
          "${aws_lb.wp_lb.arn}"
        ]
      }
    }
  ]
}
POLICY

  tags = {
    Name = "logs bucket"
  }
}
