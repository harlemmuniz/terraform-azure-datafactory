resource "azurerm_data_factory_linked_custom_service" "main" {
  name            = var.name
  data_factory_id = var.data_factory_id
  type            = lookup(var.properties, "type", null)
  description     = lookup(var.properties, "description", "Descrição do Linked Service")
  annotations     = lookup(var.properties, "annotations", [])

  dynamic "integration_runtime" {
    for_each = lookup(var.properties, "connectVia", null)[*]
    content {
      name       = lookup(var.properties.connectVia, "referenceName", null)
      parameters = lookup(var.properties.connectVia, "parameters", null)
    }
  }

  type_properties_json = <<JSON
  ${jsonencode(var.properties.typeProperties)}
JSON

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
