provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "examon-terraform-state"
    key    = "rest-api-domain-2/terraform.tfstate"
    region = "eu-west-1"
  }
}