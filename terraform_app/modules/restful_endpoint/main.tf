resource "aws_apigatewayv2_integration" "integration" {
  api_id                 = var.api_gateway_id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.integration_uri
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "proxy_route" {
  api_id = var.api_gateway_id

  route_key = "ANY ${var.path}/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_apigatewayv2_route" "route" {
  api_id = var.api_gateway_id

  route_key = "${var.method} ${var.path}"
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_cloudwatch_log_group" "api_gw_cloud_watch_group" {
  name = "/aws/api_gw2/${var.api_gateway_id}/${var.function_name}${var.path}"

  retention_in_days = var.api_gw_cloud_watch_group_retention_in_days
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_execution_arn}/*/*"
}
