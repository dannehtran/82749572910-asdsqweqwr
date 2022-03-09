terraform {
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 3.0"
    }
 }
}

# Configure the AWS Provider
provider "aws" {
    region = "us-east-1"
    # access_key = var.aws_access_key
    # secret_key = var.aws_secret_key
}

# # Create a VPC
# resource "aws_vpc" "example" {
#     cidr_block = "10.0.0.0/16"
# }