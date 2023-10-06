resource "aws_api_gateway_rest_api" "my_rest_api" {
  name = "my-rest-api"

  body = jsonencode({
    openapi = "3.0.1"
    info    = {
      title   = "example"
      version = "1.0"
    }
    paths = {
      "/path1" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "https://ip-ranges.amazonaws.com/ip-ranges.json"
          }
        }
      }
    }
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "my_rest_api" {
  rest_api_id = aws_api_gateway_rest_api.my_rest_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.my_rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.my_rest_api.id
  rest_api_id   = aws_api_gateway_rest_api.my_rest_api.id
  stage_name    = "v1"
}
