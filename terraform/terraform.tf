#################################################################################################################################
######### CONFIGURAÇÃO DE TERRAFORM PROVIDERS OBRIGATÓRIO E VERSÃO (AZURERM), E BACKEND (LOCAL ONDE ARMAZENAR TFSTATE) ##########
#################################################################################################################################

terraform {
    backend "local" {
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.105.0"
    }
  }
}
