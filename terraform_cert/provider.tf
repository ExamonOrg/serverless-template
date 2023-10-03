#https://medium.com/heyjobs-tech/quick-guide-to-adding-custom-domains-to-aws-api-gateways-using-terraform-route53-acm-and-a6d0d4de77c7

provider "aws" {
  region = "eu-west-1"
  alias  = "eu_west_1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}


terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.eu_west_1, aws.us_east_1]
    }
  }
}