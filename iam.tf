# Key Pair
# https://www.terraform.io/docs/providers/aws/r/key_pair.html
resource "aws_key_pair" "sensei_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Security groups
# https://www.terraform.io/docs/providers/aws/r/security_group.html
# Production Security Group
resource "aws_security_group" "sensei_pub_sg" {
  name        = "sensei_pub_sg"
  description = "Used for access to the EC2 instance"
  vpc_id      = aws_vpc.sensei_vpc.id

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  # For Ansible
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [var.home_ip]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Private Security Group
resource "aws_security_group" "sensei_priv_sg" {
  name        = "sensei_priv_sg"
  description = "Private security group"
  vpc_id      = aws_vpc.sensei_vpc.id

  # Access from the rest of the VPC
  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Security Group
resource "aws_security_group" "sensei_rds_sg" {
  name        = "sensei_rds_sg"
  description = "RDS instance security group"
  vpc_id      = aws_vpc.sensei_vpc.id

  ingress {
    from_port = 3306
    protocol  = "tcp"
    to_port   = 3306

    security_groups = [
      aws_security_group.sensei_pub_sg.id,
      aws_security_group.sensei_priv_sg.id
    ]
  }
}

# IAM Role
# https://www.terraform.io/docs/providers/aws/r/iam_role.html
resource "aws_iam_role" "sensei_server_role" {
  name               = "sensei-server-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM Policy
# https://www.terraform.io/docs/providers/aws/r/iam_policy.html
resource "aws_iam_policy" "sensei_server_policy" {
  name        = "sensei-server-policy"
  description = "Policy for Sensei web server to access S3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObject",
        "s3:GetBucketLocation"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.sensei_data_bucket.arn}",
        "${aws_s3_bucket.sensei_data_bucket.arn}/*"
      ],
      "Sid": ""
    },
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": "s3:ListAllMyBuckets",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM Role Attachment
# https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html
resource "aws_iam_role_policy_attachment" "sensei_role_attach" {
  policy_arn = aws_iam_policy.sensei_server_policy.arn
  role       = aws_iam_role.sensei_server_role.name
}

# Instance Profile
# https://www.terraform.io/docs/providers/aws/r/iam_instance_profile.html
resource "aws_iam_instance_profile" "sensei_server_profile" {
  name = "sensei-server-profile"
  role = aws_iam_role.sensei_server_role.name
}