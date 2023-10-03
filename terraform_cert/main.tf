#https://stackoverflow.com/questions/67606544/how-to-solve-aws-cloudfront-ssl-certificate-doesnt-exist
data "aws_route53_zone" "hosted_zone" {
  zone_id      = var.zone_id
  private_zone = false
}

resource "aws_acm_certificate" "cert" {
  provider                  = aws.us_east_1
  domain_name               = var.root_domain
  validation_method         = "DNS"
  subject_alternative_names = [
    "*.${var.root_domain}",
  ]
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.record_cert_validation : record.fqdn]
  timeouts {
    create = "45m"
  }
}

resource "aws_route53_record" "record_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

resource "aws_api_gateway_domain_name" "api_gateway_domain" {
  provider        = aws.eu_west_1
  domain_name     = var.subdomain
  certificate_arn = aws_acm_certificate.cert.arn
  depends_on      = [aws_acm_certificate_validation.cert_validation, aws_route53_record.record_cert_validation]
}

#resource "aws_route53_record" "sub_domain" {
#  provider = aws.eu_west_1
#  name     = var.subdomain
#  type     = "A"
#  zone_id  = data.aws_route53_zone.hosted_zone.zone_id
#  alias {
#    name                   = aws_api_gateway_domain_name.api_gateway_domain.cloudfront_domain_name
#    zone_id                = aws_api_gateway_domain_name.api_gateway_domain.cloudfront_zone_id
#    evaluate_target_health = true
#  }
#}


#resource "aws_route53_record" "sub_domain" {
#  zone_id = aws_route53_zone.example.zone_id
#  name    = "api.example.com"
#  type    = "A"
#  alias {
#    name                   = aws_apigatewayv2_api.example.api_endpoint
#    zone_id                = aws_route53_zone.example.zone_id
#    evaluate_target_health = false
#  }
#}
#
#output "cloudfront_domain_name" {
#  value = aws_route53_record.sub_domain.fqdn
#}