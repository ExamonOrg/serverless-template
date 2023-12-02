variable lambda_configs {
  description = "Lambda Configurations"
  type        = list(object({
    source_path = string
    name        = string
    memory_size = string
  }))
  default = [
    {
      source_path = "handlers/pet/create/package",
      name        = "petshop_create_pet",
      memory_size = 768
    },
    {
      source_path = "handlers/pet/delete/package",
      name        = "petshop_delete_pet",
      memory_size = 768
    },
    {
      source_path = "handlers/pet/index/package",
      name        = "petshop_index_pet",
      memory_size = 768
    },
    {
      source_path = "handlers/pet/get/package",
      name        = "petshop_get_pet",
      memory_size = 768
    },
    {
      source_path = "handlers/pet/update/package",
      name        = "petshop_update_pet",
      memory_size = 768
    },
  ]
}