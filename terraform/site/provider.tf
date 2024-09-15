terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.67.0"
    }
  }
  backend "s3" {
    bucket = "examon-mirror-storage-state"
    key    = "serverless.template.terraform.tfstate"
    region = "eu-west-1"
  }
}
