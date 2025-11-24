terraform {
  backend "azurerm" {
    storage_account_name = "dataprocessingtfstate"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
    resource_group_name  = "data-processing-rg"
  }
}