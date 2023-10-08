resource "aws_api_gateway_rest_api" "my_rest_api" {
  provider          = aws.eu_west_1
  name              = "my-rest-api2"
  api_key_source    = "HEADER"
  put_rest_api_mode = "merge"
  body              = file("${path.module}/../../api_specification/openapi.json")
  tags              = {}

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  provider      = aws.eu_west_1
  statement_id  = "AllowExecutionFromRestAPI"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.examon_get_questions.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.my_rest_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_lambda_permission_hello" {
  provider      = aws.eu_west_1
  statement_id  = "AllowExecutionFromRestAPI_${data.aws_lambda_function.hello.function_name}"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.hello.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.my_rest_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "my_rest_api" {
  provider    = aws.eu_west_1
  rest_api_id = aws_api_gateway_rest_api.my_rest_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.my_rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  provider      = aws.eu_west_1
  deployment_id = aws_api_gateway_deployment.my_rest_api.id
  rest_api_id   = aws_api_gateway_rest_api.my_rest_api.id
  stage_name    = "v1"
}

resource "aws_api_gateway_usage_plan" "example" {
  provider     = aws.eu_west_1
  name         = "my-usage-plan"
  description  = "my description"
  product_code = "MYCODE"

  api_stages {
    api_id = aws_api_gateway_rest_api.my_rest_api.id
    stage  = aws_api_gateway_stage.example.stage_name
  }

  quota_settings {
    limit  = 1000
    offset = 0
    period = "DAY"
  }

  throttle_settings {
    burst_limit = 10
    rate_limit  = 20
  }
}

resource "aws_api_gateway_api_key" "mykey" {
  provider = aws.eu_west_1
  name     = "my_key"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  provider      = aws.eu_west_1
  key_id        = aws_api_gateway_api_key.mykey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.example.id
}

output "invoke_url" {
  value = aws_api_gateway_deployment.my_rest_api.invoke_url
}

output "api_key_value" {
  value     = aws_api_gateway_api_key.mykey.value
  sensitive = true
}