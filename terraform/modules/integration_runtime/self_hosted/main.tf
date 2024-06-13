resource "azurerm_data_factory_integration_runtime_self_hosted" "main" {
  name            = var.name
  data_factory_id = var.data_factory_id
  description     = lookup(var.properties, "description", "")

  dynamic "rbac_authorization" {
    for_each = lookup(var.properties, "typeProperties", null) != null ? lookup(var.properties.typeProperties, "linkedInfo", null) != null && var.properties.typeProperties.linkedInfo.authorizationType == "Rbac" ? var.properties.typeProperties.linkedInfo : {} : {}
    content {
      resource_id = lookup(var.properties.typeProperties.linkedInfo, "resourceId", null)
    }
  }

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
    read   = "1m"
  }
}
