data "aws_lambda_function" "examon_get_questions" {
  provider      = aws.eu_west_1
  function_name = "examon_get_questions"
}

data "aws_lambda_function" "hello" {
  provider      = aws.eu_west_1
  function_name = "hello"
}