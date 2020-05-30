# EC2 Instance for hosting WordPress
# https://www.terraform.io/docs/providers/aws/r/instance.html
resource "aws_instance" "sensei_ec2" {
  ami                     = var.ec2_ami
  instance_type           = var.ec2_type
  availability_zone       = data.aws_availability_zones.available.names[0]
  disable_api_termination = false
  subnet_id               = aws_subnet.sensei_pub_subnet.id
  key_name                = aws_key_pair.sensei_key.key_name

  security_groups = [
    aws_security_group.sensei_pub_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.sensei_server_profile.name

  # https://www.terraform.io/docs/provisioners/local-exec.html
  provisioner "local-exec" {
    command = "echo \"all:\n  vars:\n    db_name: ${var.db_name}\n    db_user: ${var.db_user}\n    db_pass: ${var.db_pass}\n    db_host: ${aws_db_instance.sensei_db.address}\n    server_role: ${aws_iam_role.sensei_server_role.name}\n    aws_region: ${var.aws_region}\n    bucket_name: ${aws_s3_bucket.sensei_data_bucket.bucket}\n  children:\n    webservers:\n      hosts:\n        ${aws_instance.sensei_ec2.public_ip}:\" > aws_hosts"
  }

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.sensei_ec2.id} --profile terraform && ansible-playbook -i aws_hosts --private-key ${aws_key_pair.sensei_key.key_name} ec2_configure.yml"
  }

  tags = {
    Name = "Sensei Host"
  }
  volume_tags = {
    Name = "Sensei EBS"
  }
}

# RDS Instance for hosting WP Database
# https://www.terraform.io/docs/providers/aws/r/db_instance.html
resource "aws_db_instance" "sensei_db" {
  allocated_storage    = var.db_storage
  engine               = "mysql"
  engine_version       = "8.0.17"
  instance_class       = var.db_type
  name                 = var.db_name
  username             = var.db_user
  password             = var.db_pass
  db_subnet_group_name = aws_db_subnet_group.sensei_sng.name
  vpc_security_group_ids = [
    aws_security_group.sensei_rds_sg.id
  ]
  skip_final_snapshot = true
}

# S3 Bucket Policies
# https://www.terraform.io/docs/providers/aws/r/s3_bucket_policy.html
resource "aws_s3_bucket_policy" "sensei_bucket_policy" {
  bucket = aws_s3_bucket.sensei_data_bucket.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.sensei_server_role.arn}"
            },
            "Action": [
                "s3:DeleteObjectTagging",
                "s3:ListBucketMultipartUploads",
                "s3:DeleteObjectVersion",
                "s3:ListBucket",
                "s3:DeleteObjectVersionTagging",
                "s3:GetBucketAcl",
                "s3:ListMultipartUploadParts",
                "s3:PutObject",
                "s3:GetObjectAcl",
                "s3:GetObject",
                "s3:AbortMultipartUpload",
                "s3:DeleteObject",
                "s3:GetBucketLocation",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "${aws_s3_bucket.sensei_data_bucket.arn}",
                "${aws_s3_bucket.sensei_data_bucket.arn}/*"
            ]
        }
    ]
}
EOF
}

# S3 Buckets
# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
resource "aws_s3_bucket" "sensei_data_bucket" {
  bucket        = "sensei-data.senseirat.com"
  acl           = "private"
  force_destroy = false

  versioning {
    enabled = false
  }

  tags = {
    Name = "Sensei Data"
  }
}