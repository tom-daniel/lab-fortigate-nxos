terraform {
  required_providers {
    fortios = {
      source  = "fortinetdev/fortios"
      version = "1.21.1"
    }
    nxos = {
      source  = "CiscoDevNet/nxos"
      version = "0.5.5"
    }
  }
  backend "azurerm" {
    resource_group_name  = "azuks-infr-tfstate"
    storage_account_name = "tfstate19215"
    container_name       = "tfstate"               # eg "tfstate"
    key                  = "td-fortigate-nxos-lab" # eg"project-name.tfstate"
  }
}