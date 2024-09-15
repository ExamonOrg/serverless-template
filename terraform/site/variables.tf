variable lambda_configs {
  description = "Lambda Configurations"
  type        = list(object({
    source_path = string
    name        = string
    memory_size = string
  }))
  default = [
    {
      source_path = "handlers/storage/create/package",
      name        = "storage_mirror_create_storage",
      memory_size = 768
    },
    {
      source_path = "handlers/storage/get/package",
      name        = "storage_mirror_get_storage",
      memory_size = 768
    }
  ]
}
