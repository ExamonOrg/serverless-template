resource "aws_lambda_function" "myLambda" {
  function_name    = var.name
  filename         = var.filename
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  source_code_hash = var.source_code_hash
  memory_size      = var.memory_size
  role             = aws_iam_role.lambda_role.arn
  architectures    = var.architectures
  layers           = var.layers
  tags             = var.tags
  ephemeral_storage {
    size = var.ephemeral_storage_size_in_gb
  }
  environment {
    variables = var.environment
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "role_lambda_${var.name}"

  assume_role_policy = var.assume_role_policy
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

output "invoke_arn" {
  value = aws_lambda_function.myLambda.invoke_arn
}

output "function_name" {
  value = aws_lambda_function.myLambda.function_name
}