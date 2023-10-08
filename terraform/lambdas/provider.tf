provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "examon-terraform-state"
    key    = "lambdas/terraform.tfstate"
    region = "eu-west-1"
  }
}