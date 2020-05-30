# https://www.terraform.io/docs/configuration/variables.html
# Provider Variables
variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "cloudflare_email" {}
variable "cloudflare_account" {}
variable "cloudflare_api_token" {}

# VPC Variables
variable "vpc_cidr" {}
variable "cidrs" {
  type = map
}
data "aws_availability_zones" "available" {}

# IAM Variables
variable "key_name" {}
variable "public_key_path" {}
variable "home_ip" {}

# Resource Variables
variable "ec2_ami" {}
variable "ec2_type" {}
variable "db_storage" {}
variable "db_type" {}
variable "db_name" {}
variable "db_user" {}
variable "db_pass" {}

# Cloudflare Variables
variable "domain_name" {}
data "cloudflare_zones" "sensei_rat" {
  filter {
    name = var.domain_name
  }
}