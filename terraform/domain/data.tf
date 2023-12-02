data "aws_acm_certificate" "cert" {
  domain = var.certificate_domain
}

data "aws_api_gateway_rest_api" "default" {
  name = var.api_name
}

data "aws_route53_zone" "default" {
  name = var.tld
}