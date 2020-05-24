# Dev IP Variable
variable "localip" {}
variable "domain_name" {}

# Provider Variables
variable "aws_region" {}
variable "aws_profile" {}

# VPC Variables
data "aws_availability_zones" "available" {}
variable "vpc_cidr" {}

variable "cidrs" {
  type = map
}

# RDS variables
variable "db_storage" {}
variable "db_instance_class" {}
variable "dbname" {}
variable "dbuser" {}
variable "dbpassword" {}

# EC2 Variables
variable "dev_instance_type" {}
variable "dev_ami" {}
variable "public_key_path" {}
variable "key_name" {}
