resource "azurerm_data_factory" "main" {
  name                = var.name
  resource_group_name = lower(var.resource_group_name)
  location            = var.location

  dynamic "global_parameter" {
    # Bloco dinâmico, utilizado para criar um bloco para cada parâmetro citado abaixo através de um for_each
    for_each = lookup(var.properties, "globalParameters", null) != null ? var.properties.globalParameters : {}
    content {
      name  = global_parameter.key
      type  = title(global_parameter.value.type)
      value = global_parameter.value.value
    }
  }
  
  # Valores fixos, contidas em todos os adfs
  tags = {
    manage: "data_engineering",
  }

  # vsts_configuration {
  #   account_name = ""
  #   branch_name = ""
  #   project_name = ""
  #   repository_name = ""
  #   root_folder = ""
  #   tenant_id = ""
  # }

  # identity {
  #   type = "SystemAssigned"
  #   identity_ids = ["00000000-0000-0000-0000-000000000000"]
  # }

  # managed_virtual_network_enabled = a
  # managed_virtual_network_enabled = false
  # public_network_enabled = false
  # customer_managed_key_identity_id = "a"
  # customer_managed_key_id = "a"
  # purview_id = ""
  
  lifecycle {
    ignore_changes = [ vsts_configuration ]
    prevent_destroy = true
  }
  
  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
    read   = "1m"
  }
}