module "restapi" {
  source                      = "git::https://github.com/ExamonOrg/tf-modules.git//rest_api"
  api_name                    = "rest-api"
  open_api_json_relative_path = "../../api_specification/openapi.json"
}
