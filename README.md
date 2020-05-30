# Sensei Rat Blog
## Introduction
This is a short terraform+ansible project that I put together to create and 
fully configure a WordPress blog in AWS.  It stays completely within the AWS 
free tier, which is why CloudFlare is used to provide DNS/CDN services.  S3 
charges may be incurred by high traffic.

## Configuration
A sample tfvars file has been provided that needs to be populated with the 
correct values before running this.  While there are significantly more 
appropriate methods of storing secrets, I didn't want to build out more 
infrastructure than was really required to run the blog, and for personal 
use, this is sufficient.
