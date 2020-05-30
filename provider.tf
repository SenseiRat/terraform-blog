# https://www.terraform.io/docs/providers/aws/index.html
provider "aws" {
  version    = "~> 2.63"
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# https://www.terraform.io/docs/providers/cloudflare/index.html
provider "cloudflare" {
  email      = var.cloudflare_email
  account_id = var.cloudflare_account
  api_token  = var.cloudflare_api_token
}