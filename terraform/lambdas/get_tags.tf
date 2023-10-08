data "archive_file" "get_tags_src" {
  type        = "zip"
  source_dir  = "${path.module}/../../handlers/get_tags/package"
  output_path = "${path.module}/zip_files/get_tags.zip"
}

module "get_tags_lambda" {
  source           = "../../../tf-modules/lambda_ot"
  source_code_hash = data.archive_file.get_tags_src.output_base64sha256
  name             = "examon_get_tags"
  filename         = "${path.module}/zip_files/get_tags.zip"
}
