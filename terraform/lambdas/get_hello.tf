data "archive_file" "get_hello_src" {
  type        = "zip"
  source_dir  = "${path.module}/../../handlers/hello"
  output_path = "${path.module}/zip_files/hello.zip"
}

module "get_hello_lambda" {
  source           = "../../../tf-modules/lambda"
  source_code_hash = data.archive_file.get_tags_src.output_base64sha256
  name             = "hello"
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  filename         = "${path.module}/zip_files/hello.zip"
}
