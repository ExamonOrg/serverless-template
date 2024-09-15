module "my_dynamodb" {
  source              = "git::https://github.com/ExamonOrg/tf-modules.git//dynamodb?ref=v1"
  table_name          = "mirror_storage"
  hash_key            = "object_name"
  enable_streams      = true
  stream_view_type    = "NEW_AND_OLD_IMAGES"
  dynamodb_attributes = tolist([
    {
      name = "object_name"
      type = "S"
    }
  ])
}
