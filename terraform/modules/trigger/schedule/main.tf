resource "azurerm_data_factory_trigger_schedule" "main" {
  name            = var.name
  data_factory_id = var.data_factory_id
  activated       = var.ambiente == "prod" ? true : false

  description = lookup(var.properties, "description", "Descrição da trigger")
  frequency   = lookup(var.properties.typeProperties.recurrence, "frequency", null)
  interval    = lookup(var.properties.typeProperties.recurrence, "interval", null)
  annotations = lookup(var.properties, "annotations", [])

  dynamic "pipeline" {
    for_each = lookup(var.properties, "pipelines", null)
    content {
      name       = lookup(pipeline.value.pipelineReference, "referenceName", null)
      parameters = lookup(pipeline.value, "parameters", null)
    }
  }

  schedule {
    days_of_week  = lookup(var.properties.typeProperties.recurrence.schedule, "weekDays", null)
    days_of_month = lookup(var.properties.typeProperties.recurrence.schedule, "monthDays", null)
    hours         = lookup(var.properties.typeProperties.recurrence.schedule, "hours", null)
    minutes       = lookup(var.properties.typeProperties.recurrence.schedule, "minutes", null)

    dynamic "monthly" {
      for_each = lookup(var.properties.typeProperties.recurrence.schedule, "monthlyOccurrences", null) == null ? [] : lookup(var.properties.typeProperties.recurrence.schedule, "monthlyOccurrences", null)
      content {
        weekday = lookup(monthly.value, "day", null)
        week    = lookup(monthly.value, "occurrence", null)
      }
    }
  }

  start_time = lookup(var.properties.typeProperties.recurrence, "startTime", null) != null ? "${trimsuffix(var.properties.typeProperties.recurrence.startTime, "Z")}Z" : null
  end_time   = lookup(var.properties.typeProperties.recurrence, "endTime", null) != null ? "${trimsuffix(var.properties.typeProperties.recurrence.endTime, "Z")}Z" : null
  time_zone   = lookup(var.properties.typeProperties.recurrence, "timeZone", null)
  
  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
    read   = "1m"
  }
}