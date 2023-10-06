variable "source_code_hash" {}
variable "name" {}
variable "filename" {}
variable "environment" {
  default = {}
}
variable "handler" {
    default = "src.main.lambda_handler"
}
variable "runtime" {
  default = "python3.10"
}
variable "tags" {
    default = {
        "Terraform" = "true"
        "Application" = "examon"
    }
}
#https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html
variable "layers" {
  default = []
}
#https://registry.terraform.io/providers/-/aws/latest/docs/resources/lambda_function#ephemeral_storage
variable "ephemeral_storage_size_in_gb" {
  default = 512
}
# https://registry.terraform.io/providers/-/aws/latest/docs/resources/lambda_function#architectures
variable "architectures" {
  default = ["x86_64"]
}
# https://registry.terraform.io/providers/-/aws/latest/docs/resources/lambda_function#memory_size
variable "memory_size" {
    default = 128
}
# https://registry.terraform.io/providers/-/aws/latest/docs/resources/lambda_function#timeout
variable "timeout" {
  default = 120
}
variable "assume_role_policy" {
  default = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}