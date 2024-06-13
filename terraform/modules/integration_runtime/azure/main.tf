resource "azurerm_data_factory_integration_runtime_azure" "main" {
  name                    = var.name
  data_factory_id         = var.data_factory_id
  description             = lookup(var.properties, "description", "")
  location                = lookup(var.properties, "typeProperties", null) != null ? lookup(var.properties.typeProperties, "computeProperties", null) != null ? lookup(var.properties.typeProperties.computeProperties, "location", null) : null : null
  compute_type            = lookup(var.properties, "typeProperties", null) != null ? lookup(var.properties.typeProperties, "computeProperties", null) != null ? lookup(var.properties.typeProperties.computeProperties, "dataFlowProperties", null) != null ? lookup(var.properties.typeProperties.computeProperties.dataFlowProperties, "computeType", "General") : null : null : null
  core_count              = lookup(var.properties, "typeProperties", null) != null ? lookup(var.properties.typeProperties, "computeProperties", null) != null ? lookup(var.properties.typeProperties.computeProperties, "dataFlowProperties", null) != null ? lookup(var.properties.typeProperties.computeProperties.dataFlowProperties, "coreCount", 8) : null : null : null
  time_to_live_min   = lookup(var.properties, "typeProperties", null) != null ? lookup(var.properties.typeProperties, "computeProperties", null) != null ? lookup(var.properties.typeProperties.computeProperties, "dataFlowProperties", null) != null ? lookup(var.properties.typeProperties.computeProperties.dataFlowProperties, "timeToLive", 0) : null : null : null
  virtual_network_enabled = lookup(var.properties, "managedVirtualNetwork", null) != null ? true : false
  cleanup_enabled         = lookup(var.properties, "typeProperties", null) != null ? lookup(var.properties.typeProperties, "computeProperties", null) != null ? lookup(var.properties.typeProperties.computeProperties, "dataFlowProperties", null) != null ? lookup(var.properties.typeProperties.computeProperties.dataFlowProperties, "cleanup", true) : null : null : null
  
  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
    read   = "1m"
  }
}
