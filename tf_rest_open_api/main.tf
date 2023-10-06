resource "aws_api_gateway_rest_api" "my_rest_api" {
  name = "my-rest-api2"

  body = file("${path.module}/openapi.json")

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromRestAPI"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.examon_get_questions.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.my_rest_api.execution_arn}/*/*"
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
