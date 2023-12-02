output "invoke_url" {
  value = module.restapi.invoke_url
}

output "api_key_value" {
  value     = module.restapi.api_key_value
  sensitive = true
}