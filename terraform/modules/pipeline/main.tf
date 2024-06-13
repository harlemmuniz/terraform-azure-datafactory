resource "azurerm_data_factory_pipeline" "main" {
  activities_json = <<JSON
  ${jsonencode(var.properties.activities)}
JSON
  name            = var.name
  data_factory_id = var.data_factory_id
  description     = lookup(var.properties, "description", "Descrição do pipeline")
  annotations     = lookup(var.properties, "annotations", [])
  concurrency     = lookup(var.properties, "concurrency", null)
  folder          = contains(keys(var.properties), "folder") == true ? var.properties.folder.name : null

  parameters = (
    lookup(var.properties, "parameters", null) != null ? {
      for key, value in zipmap(keys(var.properties.parameters), values(var.properties.parameters)) :
    key => try(value.defaultValue, "") } : null
  )

  variables = (
    lookup(var.properties, "variables", null) != null ? {
      for key, value in zipmap(keys(var.properties.variables), values(var.properties.variables)) :
    key => try(value.defaultValue, "") } : null
  )

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
    read   = "1m"
  }
}