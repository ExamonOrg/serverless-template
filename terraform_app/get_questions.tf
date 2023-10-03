data "archive_file" "get_questions_src" {
  type        = "zip"
  source_dir  = "${path.module}/../handlers/get_questions/package"
  output_path = "${path.module}/zip_files/get_questions.zip"
}

module "get_questions_lambda" {
  source           = "./modules/lambda_ot"
  source_code_hash = data.archive_file.get_questions_src.output_base64sha256
  name             = "examon_get_questions"
  memory_size      = 768
  filename         = "${path.module}/zip_files/get_questions.zip"
}

module "api_gateway_v2_get_questions" {
  source                    = "./modules/restful_endpoint"
  method                    = "GET"
  path                      = "/questions"
  stage_name                = "staging"
  integration_uri           = module.get_questions_lambda.invoke_arn
  function_name             = module.get_questions_lambda.function_name
  api_gateway_id            = aws_apigatewayv2_api.api_gw.id
  api_gateway_execution_arn = aws_apigatewayv2_api.api_gw.execution_arn
}
