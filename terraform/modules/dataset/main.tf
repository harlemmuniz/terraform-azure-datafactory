resource "azurerm_data_factory_custom_dataset" "main" {
  name            = var.name
  data_factory_id = var.data_factory_id
  type            = lookup(var.properties, "type", null)
  description     = lookup(var.properties, "description", "Descrição do Dataset")
  annotations     = lookup(var.properties, "annotations", [])
  folder          = lookup(var.properties, "folder", null) != null ? lookup(var.properties.folder, "name", null) : null

  linked_service {
    name       = lookup(var.properties.linkedServiceName, "referenceName", null)
    parameters = lookup(var.properties.linkedServiceName, "parameters", null)
  }

  type_properties_json = contains(keys(var.properties), "typeProperties") ? jsonencode(var.properties.typeProperties) : jsonencode({})

  schema_json = contains(keys(var.properties), "schema") ? jsonencode(var.properties.schema) : null

  additional_properties = try(var.additional_properties, null)

  parameters = (
    can(var.properties.parameters) ? (var.properties.parameters != null ? {
      for key, value in zipmap(keys(var.properties.parameters), values(var.properties.parameters)) :
    key => try(value.defaultValue, "") } : null) : null
  )
  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
    read   = "1m"
  }
}