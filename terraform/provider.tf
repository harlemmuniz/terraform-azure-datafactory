#################################################################################################################################
############################ CONFIGURAÇÃO DO PROVIDER UTILIZADO PELOS ROOT E CHILD MODULES (AZURERM) ############################
######################## DENTRO DE features {} INFORMAÇÃO CONFIGURAÇÕES NECESSÁRIAS (NÃO OBRIGATÓRIO) ###########################
#################################################################################################################################

provider "azurerm" {
  features {
  }

  # subscription_id = "00000000-0000-0000-0000-000000000000"
  skip_provider_registration = true
}