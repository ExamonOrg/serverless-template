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
  backend "s3" {
    bucket = "examon-terraform-state"
    key    = "rest-open-api/terraform.tfstate"
    region = "eu-west-1"
  }
}