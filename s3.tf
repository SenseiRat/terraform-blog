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

  tags = {
    Name = "logs bucket"
  }
}
