resource "random_id" "wp_code_bucket" {
  byte_length = 2
}

resource "aws_s3_bucket" "code" {
  bucket = "${var.domain_name}-${random_id.wp_code_bucket.dec}"
  acl = "private"
  force_destroy = true

  tags = {
    Name = "code bucket"
  }
}

resource "random_id" "wp_data_bucket" {
  byte_length = 2
}

resource "aws_s3_bucket" "data" {
  bucket = "${var.domain_name}-${random_id.wp_data_bucket.dec}"
  acl = "private"
  force_destroy = true

  tags = {
    Name = "data bucket"
  }
}
