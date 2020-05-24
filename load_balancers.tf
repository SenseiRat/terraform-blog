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

# Autoscaling Group
resource "aws_autoscaling_group" "wp_asg" {
  name = "asg-${aws_launch_configuration.wp_lc.id}"
  max_size = var.asg_max
  min_size = var.asg_min
  health_check_grace_period = var.asg_grace
  health_check_type = var.asg_hct
  desired_capacity = var.asg_cap
  force_delete = true
  load_balancers = [
    aws_lb.wp_lb.id
  ]

  vpc_zone_identifier = [
    aws_subnet.wp_private1_subnet.id,
    aws_subnet.wp_private2_subnet.id
  ]

  launch_configuration = aws_launch_configuration.wp_lc.name

  tag {
    key = "Name"
    value = "wp_asg-instance"
    propagate_at_launch = true
  }
  
  lifecycle {
    create_before_destroy = true
  }
}
