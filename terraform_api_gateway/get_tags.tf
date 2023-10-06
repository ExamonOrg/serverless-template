#data "archive_file" "get_tags_src" {
#  type        = "zip"
#  source_dir  = "${path.module}/../handlers/get_tags/package"
#  output_path = "${path.module}/zip_files/get_tags.zip"
#}
#
#module "get_tags_lambda" {
#  source           = "../modules/lambda_ot"
#  source_code_hash = data.archive_file.get_tags_src.output_base64sha256
#  name             = "examon_get_tags"
#  filename         = "${path.module}/zip_files/get_tags.zip"
#}

data "aws_lambda_function" "get_tags_lambda" {
  function_name = "examon_get_tags"
}

module "api_gateway_v2_get_tags" {
  source                    = "../modules/restful_endpoint"
  method                    = "GET"
  path                      = "/tags"
  stage_name                = "staging"
  integration_uri           = data.aws_lambda_function.get_tags_lambda.invoke_arn
  function_name             = data.aws_lambda_function.get_tags_lambda.function_name
  api_gateway_id            = aws_apigatewayv2_api.api_gw.id
  api_gateway_execution_arn = aws_apigatewayv2_api.api_gw.execution_arn
}
