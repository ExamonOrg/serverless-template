data "archive_file" "get_questions_src" {
  type        = "zip"
  source_dir  = "${path.module}/../../handlers/get_questions/package"
  output_path = "${path.module}/zip_files/get_questions.zip"
}

module "get_questions_lambda" {
  source           = "../../../tf-modules/lambda_ot"
  source_code_hash = data.archive_file.get_questions_src.output_base64sha256
  name             = "examon_get_questions"
  memory_size      = 768
  filename         = "${path.module}/zip_files/get_questions.zip"
}
