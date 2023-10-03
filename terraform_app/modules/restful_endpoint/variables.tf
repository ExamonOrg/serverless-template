variable "integration_uri" {}
variable "function_name" {}
variable "path" {}
variable "method" {}
variable "api_gateway_id" {}
variable "api_gateway_execution_arn" {}
variable "api_gw_cloud_watch_group_retention_in_days" {
  default = 14
}
variable "stage_name" {
  default = "dev"
}
