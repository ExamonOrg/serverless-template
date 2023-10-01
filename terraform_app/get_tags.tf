data "archive_file" "get_tags_src" {
  type        = "zip"
  source_dir  = "${path.module}/../handlers/get_tags/package"
  output_path = "${path.module}/zip_files/get_tags.zip"
}


module "get_tags_lambda" {
  source           = "./modules/lambda_ot"
  source_code_hash = data.archive_file.get_tags_src.output_base64sha256
  name             = "examon_get_tags"
  filename         = "${path.module}/zip_files/get_tags.zip"
}


module "api_gateway_v2_get_tags" {
  source          = "./modules/api_gateway_v2"
  method          = "GET"
  path            = "/tags"
  stage_name      = "staging"
  integration_uri = module.get_tags_lambda.invoke_arn
  function_name   = module.get_tags_lambda.function_name
}

output "invoke_url_get_tags" {
  value = module.api_gateway_v2_get_tags.invoke_url
}
