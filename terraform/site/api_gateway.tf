module "restapi" {
  source                      = "git::https://github.com/ExamonOrg/tf-modules.git//rest_api"
  api_name                    = "rest-api"
  open_api_json_relative_path = "/Users/jarrod.folino/Dev/examon-proj/serverless-template/api_specification/openapi.json"
}
