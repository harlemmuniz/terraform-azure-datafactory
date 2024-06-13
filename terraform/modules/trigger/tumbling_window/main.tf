resource "azurerm_data_factory_trigger_tumbling_window" "main" {
  name            = var.name
  data_factory_id = var.data_factory_id
  activated       = var.ambiente == "prod" ? true : false

  description     = lookup(var.properties, "description", "Descrição da trigger")
  frequency       = lookup(var.properties.typeProperties, "frequency", null)
  interval        = lookup(var.properties.typeProperties, "interval", null)
  annotations     = lookup(var.properties, "annotations", [])
  delay           = lookup(var.properties.typeProperties, "delay", null)
  max_concurrency = lookup(var.properties.typeProperties, "maxConcurrency", 1)

  retry {
    count    = lookup(var.properties.typeProperties.retryPolicy, "count", 0)
    interval = lookup(var.properties.typeProperties.retryPolicy, "intervalInSeconds", 30)
  }

  start_time = lookup(var.properties.typeProperties, "startTime", null) != null ? "${trimsuffix(var.properties.typeProperties.startTime, "Z")}Z" : null
  end_time   = lookup(var.properties.typeProperties, "endTime", null) != null ? "${trimsuffix(var.properties.typeProperties.endTime, "Z")}Z" : null

  pipeline {
    name = lookup(var.properties.pipeline.pipelineReference, "referenceName", null)
    parameters = (
      lookup(var.properties.pipeline, "parameters", null) != null ? {
        for key, value in zipmap(keys(var.properties.pipeline.parameters), values(var.properties.pipeline.parameters)) :
      key => try(value.value, value) } : null
    )
  }

  dynamic "trigger_dependency" {
    for_each = try(var.properties.typeProperties.dependsOn, null)[*]
    content {
      trigger_name = lookup(trigger_dependency.value, "referenceTrigger", null) != null ? lookup(trigger_dependency.value.referenceTrigger, "referenceName", null) : null
      offset       = lookup(trigger_dependency.value, "offset", null)
      size         = lookup(trigger_dependency.value, "size", null)
    }
  }

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
    read   = "1m"
  }
}
