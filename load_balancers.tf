resource "aws_lb" "wp_lb" {
  name = "${var.domain_name}-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.wp_public_sg.id
  ]

  subnets = [
    aws_subnet.wp_public1_subnet.id,
    aws_subnet.wp_public2_subnet.id
  ]

  enable_deletion_protection = false
  enable_http2 = true
  drop_invalid_header_fields = false

  access_logs {
    bucket = aws_s3_bucket.logs.bucket
    prefix = "wp-lb"
    enabled = true
  }

  tags = {
    Name = "wp_lb"
  }
}
