module "restapi" {
  source                      = "../../../tf-modules/rest_api"
  api_name                    = "rest-api"
  open_api_json_relative_path = "/Users/jarrod.folino/Dev/examon-proj/examon-api/api_specification/openapi.json"
}
