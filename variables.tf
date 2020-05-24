# Dev IP Variable
variable "localip" {}

# Provider Variables
variable "aws_region" {}
variable "aws_profile" {}

# VPC Variables
data "aws_availability_zones" "available" {}
variable "vpc_cidr" {}

variable "cidrs" {
  type = map
}
