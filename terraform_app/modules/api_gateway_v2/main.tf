resource "aws_apigatewayv2_api" "api_gw" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.api_gw.id

  name        = var.stage_name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_cloud_watch_group.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    }
    )
  }
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id                 = aws_apigatewayv2_api.api_gw.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.integration_uri
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "hello_world" {
  api_id = aws_apigatewayv2_api.api_gw.id

  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_apigatewayv2_route" "route" {
  api_id = aws_apigatewayv2_api.api_gw.id

  route_key = "${var.method} ${var.path}"
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"
}


resource "aws_cloudwatch_log_group" "api_gw_cloud_watch_group" {
  name = "/aws/api_gw2/${aws_apigatewayv2_api.api_gw.name}/${var.function_name}${var.path}"

  retention_in_days = var.api_gw_cloud_watch_group_retention_in_days
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api_gw.execution_arn}/*/*"
}

output "invoke_url" {
  value = "${aws_apigatewayv2_stage.lambda.invoke_url}${var.path}"
}

