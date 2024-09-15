module "rest_api_lambdas" {
  for_each    = {for i, v in var.lambda_configs :  i => v}
  source      = "git::https://github.com/ExamonOrg/tf-modules.git//lambda?ref=v1"
  source_dir  = "${path.module}/../../${each.value.source_path}"
  name        = each.value.name
  memory_size = each.value.memory_size
}

module "permission" {
  source          = "git::https://github.com/ExamonOrg/tf-modules.git//api_gw_lambda_permission?ref=v1"
  for_each        = {for i, v in var.lambda_configs :  i => v}
  function_name   = each.value.name
  api_gateway_arn = module.restapi.execution_arn
}
