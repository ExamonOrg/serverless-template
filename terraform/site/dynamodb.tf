module "my_dynamodb" {
  source              = "git::https://github.com/ExamonOrg/tf-modules.git//dynamodb?ref=v1"
  table_name          = "pets"
  hash_key            = "pet_uuid"
  enable_streams      = true
  stream_view_type    = "NEW_AND_OLD_IMAGES"
  dynamodb_attributes = tolist([
    {
      name = "pet_uuid"
      type = "S"
    },
    {
      name = "breed"
      type = "S"
    }
  ])

  global_secondary_index_map = [
    {
      name               = "pet_breed_index"
      hash_key           = "pet_uuid"
      range_key          = "breed"
      write_capacity     = 5
      read_capacity      = 5
      projection_type    = "INCLUDE"
      non_key_attributes = ["HashKey"]
    }
  ]
}
