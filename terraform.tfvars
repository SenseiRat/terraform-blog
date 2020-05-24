aws_profile = "terraform"
aws_region  = "us-east-2"
vpc_cidr = "10.1.0.0/16"
cidrs = {
  public1 = "10.1.1.0/24"
  public2 = "10.1.2.0/24"
  private1 = "10.1.3.0/24"
  private2 = "10.1.4.0/24"
  rds1 = "10.1.5.0/24"
  rds2 = "10.1.6.0/24"
  rds3 = "10.1.7.0/24"
}
localip = "209.6.72.119/32"
