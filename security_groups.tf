# Dev Security Group
resource "aws_security_group" "wp_dev_sg" {
  name = "wp_dev_sg"
  description = "Used for access to the dev instance"
  vpc_id = aws_vpc.wp_vpc.id

  # SSH Rules
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.localip]
  }

  # HTTP Rules
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.localip]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Production Security Group
resource "aws_security_group" "wp_public_sg" {
  name = "wp_public_sg"
  description = "Used for the elb for public access"
  vpc_id = aws_vpc.wp_vpc.id

  # HTTP Rules
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Private Security Group
resource "aws_security_group" "wp_private_sg" {
  name = "wp_private_sg"
  description = "Private security group"
  vpc_id = aws_vpc.wp_vpc.id

  # Access from rest of VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Security Group
resource "aws_security_group" "wp_rds_sg" {
  name = "wp_rds_sg"
  description = "RDS instance security group"
  vpc_id = aws_vpc.wp_vpc.id

  # SQL Access from public and private sgs
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
  
    security_groups = [
      aws_security_group.wp_dev_sg.id,
      aws_security_group.wp_public_sg.id,
      aws_security_group.wp_private_sg.id
    ]
  }
}
