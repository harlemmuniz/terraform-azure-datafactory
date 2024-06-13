locals {
  factory_files = fileset("../factory/", "*.json")
  factory_data = [for f in local.factory_files : jsondecode(file("../factory/${f}"))]

  integration_runtime_files = fileset("../integrationRuntime/", "*.json")
  integration_runtime_data  = [for f in local.integration_runtime_files : jsondecode(file("../integrationRuntime/${f}"))]

  linked_service_files = fileset("../linkedService/", "*.json")
  linked_service_data  = [for f in local.linked_service_files : jsondecode(file("../linkedService/${f}"))]

  dataset_files = fileset("../dataset/", "*.json")
  dataset_data  = [for f in local.dataset_files : jsondecode(file("../dataset/${f}"))]

  pipeline_files = fileset("../pipeline/", "*.json")
  pipeline_data  = [for f in local.pipeline_files : jsondecode(file("../pipeline/${f}"))]

  trigger_files = fileset("../trigger/", "*.json")
  trigger_data  = [for f in local.trigger_files : jsondecode(file("../trigger/${f}"))]
}

module "data_factory_factory_module" {
  source          = "./modules/factory"
  data_factory_id = var.data_factory_id
  ambiente        = var.ambiente

  for_each   = { for f in local.factory_data : "${trimsuffix(lower(f.name), "-lab")}-${var.ambiente}" => f }
  name       = "${trimsuffix(lower(each.value.name), "-lab")}-${var.ambiente}"
  properties = lookup(each.value, "properties", null)
  location   = lookup(each.value, "location", null)

  resource_group_name = var.resource_group_name
}

module "data_factory_integration_runtime_self_hosted_module" {
  source          = "./modules/integration_runtime/self_hosted"
  data_factory_id = var.data_factory_id

  for_each   = { for f in local.integration_runtime_data : f.name => f if f.properties.type == "SelfHosted" }
  name       = lookup(each.value, "name", null)
  properties = lookup(each.value, "properties", null)

  # depends_on = [module.data_factory_factory_module]
}

module "data_factory_integration_runtime_azure_module" {
  source          = "./modules/integration_runtime/azure"
  data_factory_id = var.data_factory_id

  for_each   = { for f in local.integration_runtime_data : f.name => f if f.properties.type == "Managed"}
  name       = lookup(each.value, "name", null)
  properties = lookup(each.value, "properties", null)

  # depends_on = [module.data_factory_factory_module]
}

module "data_factory_key_vault_linked_service_module" {
  source          = "./modules/linked_service"
  data_factory_id = var.data_factory_id

  for_each              = { for f in local.linked_service_data : f.name => f if strcontains(f.name, "keyvault") }
  name                  = lookup(each.value, "name", null)
  properties            = lookup(each.value, "properties", null)
  additional_properties = lookup(each.value, "additionalProperties", null)

  depends_on = [module.data_factory_integration_runtime_self_hosted_module, module.data_factory_integration_runtime_azure_module]
}

module "data_factory_linked_service_module" {
  source          = "./modules/linked_service"
  data_factory_id = var.data_factory_id

  for_each              = { for f in local.linked_service_data : f.name => f if !strcontains(f.name, "keyvault") }
  name                  = lookup(each.value, "name", null)
  properties            = lookup(each.value, "properties", null)
  additional_properties = lookup(each.value, "additionalProperties", null)

  depends_on = [module.data_factory_integration_runtime_self_hosted_module, module.data_factory_integration_runtime_azure_module, module.data_factory_key_vault_linked_service_module]
}

module "data_factory_dataset_module" {
  source          = "./modules/dataset"
  data_factory_id = var.data_factory_id

  for_each              = { for f in local.dataset_data : f.name => f }
  name                  = lookup(each.value, "name", null)
  properties            = lookup(each.value, "properties", null)
  additional_properties = lookup(each.value, "additionalProperties", null)

  depends_on = [module.data_factory_linked_service_module]
}

module "data_factory_pipeline_module" {
  source          = "./modules/pipeline"
  data_factory_id = var.data_factory_id

  for_each   = { for f in local.pipeline_data : f.name => f if !strcontains(f.name, "seq_principal_") && !strcontains(f.name, "seq_reprocessamento_") }
  name       = lookup(each.value, "name", null)
  properties = lookup(each.value, "properties", null)

  depends_on = [module.data_factory_dataset_module]
}

module "data_factory_pipeline_seq_principal_module" {
  source          = "./modules/pipeline"
  data_factory_id = var.data_factory_id

  for_each   = { for f in local.pipeline_data : f.name => f if strcontains(f.name, "seq_principal_") }
  name       = lookup(each.value, "name", null)
  properties = lookup(each.value, "properties", null)

  depends_on = [module.data_factory_dataset_module, module.data_factory_pipeline_module]
}

module "data_factory_pipeline_seq_reprocessamento_module" {
  source          = "./modules/pipeline"
  data_factory_id = var.data_factory_id

  for_each   = { for f in local.pipeline_data : f.name => f if strcontains(f.name, "seq_reprocessamento_") }
  name       = lookup(each.value, "name", null)
  properties = lookup(each.value, "properties", null)

  depends_on = [module.data_factory_dataset_module, module.data_factory_pipeline_module, module.data_factory_pipeline_seq_principal_module]
}

module "data_factory_trigger_schedule_module" {
  source          = "./modules/trigger/schedule"
  data_factory_id = var.data_factory_id
  ambiente        = var.ambiente

  for_each   = { for f in local.trigger_data : f.name => f if f.properties.type == "ScheduleTrigger" }
  name       = lookup(each.value, "name", null)
  properties = lookup(each.value, "properties", null)

  depends_on = [module.data_factory_pipeline_seq_principal_module, module.data_factory_pipeline_module]
}

module "data_factory_trigger_tumbling_window_module" {
  source          = "./modules/trigger/tumbling_window"
  data_factory_id = var.data_factory_id
  ambiente        = var.ambiente

  for_each   = { for f in local.trigger_data : f.name => f if f.properties.type == "TumblingWindowTrigger" }
  name       = lookup(each.value, "name", null)
  properties = lookup(each.value, "properties", null)

  depends_on = [module.data_factory_pipeline_seq_principal_module, module.data_factory_pipeline_module]
}