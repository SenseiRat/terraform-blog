# VPC
# https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "sensei_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "sensei_vpc"
  }
}

# Internet Gateway
# https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
resource "aws_internet_gateway" "sensei_igw" {
  vpc_id = aws_vpc.sensei_vpc.id

  tags = {
    Name = "sensei_igw"
  }
}

# Public Route Table
# https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "sensei_pub_rt" {
  vpc_id = aws_vpc.sensei_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sensei_igw.id
  }

  tags = {
    Name = "sensei_pub_rt"
  }
}

# Private Route Table
# https://www.terraform.io/docs/providers/aws/r/default_route_table.html
resource "aws_default_route_table" "sensei_priv_rt" {
  default_route_table_id = aws_vpc.sensei_vpc.default_route_table_id

  tags = {
    Name = "sensei_priv_rt"
  }
}

# Subnets
# https://www.terraform.io/docs/providers/aws/r/subnet.html
# Public Subnet
resource "aws_subnet" "sensei_pub_subnet" {
  vpc_id                  = aws_vpc.sensei_vpc.id
  cidr_block              = var.cidrs["public"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Sensei Public Subnet"
  }
}

# Private Subnet
resource "aws_subnet" "sensei_priv_subnet" {
  vpc_id                  = aws_vpc.sensei_vpc.id
  cidr_block              = var.cidrs["private"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Sensei Private Subnet"
  }
}

# RDS Subnets
resource "aws_subnet" "sensei_rds1_subnet" {
  vpc_id                  = aws_vpc.sensei_vpc.id
  cidr_block              = var.cidrs["rds1"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Sensei RDS Subnet 1"
  }
}

resource "aws_subnet" "sensei_rds2_subnet" {
  vpc_id                  = aws_vpc.sensei_vpc.id
  cidr_block              = var.cidrs["rds2"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Sensei RDS Subnet 2"
  }
}

# Subnet Groups
# https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html
resource "aws_db_subnet_group" "sensei_sng" {
  name = "sensei-subnetgroup"
  subnet_ids = [
    aws_subnet.sensei_rds1_subnet.id,
    aws_subnet.sensei_rds2_subnet.id
  ]

  tags = {
    Name = "Sensei DB Subnet Group"
  }
}

# Route Table Associations
# https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "sensei_pub_assoc" {
  subnet_id      = aws_subnet.sensei_pub_subnet.id
  route_table_id = aws_route_table.sensei_pub_rt.id
}

# AWS Endpoint for S3
# https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html
resource "aws_vpc_endpoint" "sensei_priv_s3_end" {
  vpc_id       = aws_vpc.sensei_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  route_table_ids = [
    aws_vpc.sensei_vpc.main_route_table_id,
    aws_route_table.sensei_pub_rt.id
  ]

  policy = <<POLICY
{
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "*",
      "Resource": [
        "*",
        "arn:aws:s3:::repo.us-east-2.amazonaws.com",
        "arn:aws:s3:::repo.eu-east-2.amazonaws.com/*"
      ]
    }
  ]
}
POLICY

  tags = {
    Name = "Sensei VPC Endpoint for S3"
  }
}