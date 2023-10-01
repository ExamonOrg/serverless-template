locals {
  open_telemetry_aws_managed_lambda_layer = "arn:aws:lambda:eu-west-1:901920570463:layer:aws-otel-python-amd64-ver-1-19-0:1"
  open_telemetry_aws_managed_lambda_layer_exec_wrapper = "/opt/otel-instrument"
  open_telemetry_propagators = "xray"
  open_telemetry_extension_log_level = "error"
}
