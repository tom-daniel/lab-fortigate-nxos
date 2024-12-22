terraform {
  required_providers {
  }
  backend "azurerm" {
    resource_group_name  = "azuks-infr-tfstate"
    storage_account_name = "tfstate19215"
    container_name       = ""    # eg "tfstate"
    key                  = ""    # eg"project-name.tfstate"
  }
}