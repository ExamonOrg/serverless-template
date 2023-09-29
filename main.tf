#export AWS_ACCESS_KEY_ID="AKIAW6URCXUW4SB7XHXZ"
#export AWS_SECRET_ACCESS_KEY="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"
#export AWS_REGION="eu-west-1"

provider "aws" {
  region = "eu-west-1"
}

data "archive_file" "python_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/handlers/get_questions"
  output_path = "${path.module}/app.zip"
}

resource "aws_lambda_function" "myLambda" {
  function_name    = "examon_get_questions"
  filename         = "${path.module}/app.zip"
  handler          = "src.main.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.python_lambda.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
}


//// IAM
resource "aws_iam_role" "lambda_role" {
  name = "role_lambda"

  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

//// Gateway
resource "aws_apigatewayv2_api" "hello_api_gw" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.hello_api_gw.id

  name        = "staging"
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

resource "aws_apigatewayv2_integration" "hello_world_integration" {
  api_id = aws_apigatewayv2_api.hello_api_gw.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.myLambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "hello_world" {
  api_id = aws_apigatewayv2_api.hello_api_gw.id

  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.hello_world_integration.id}"
}

resource "aws_cloudwatch_log_group" "api_gw_cloud_watch_group" {
  name = "/aws/api_gw2/${aws_apigatewayv2_api.hello_api_gw.name}"

  retention_in_days = 5
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.myLambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.hello_api_gw.execution_arn}/*/*"
}

output "invoke_url" {
  value = aws_apigatewayv2_stage.lambda.invoke_url
}
