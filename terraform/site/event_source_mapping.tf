resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn  = module.my_dynamodb.table_stream_arn
  function_name     = module.dynamo_db_event_source_lambdas.arn
  starting_position = "LATEST"
}
