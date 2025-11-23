# main.tf
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}

  # If you have many subscriptions, specify one (optional)
  subscription_id = "8d42870d-3e7a-48d8-8dcf-8b20ed4c5ad6"
}

# Example: create Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-terraform-example"
  location = "Southeast Asia"
}

output "resource_group_id" {
  value = azurerm_resource_group.example.id
}
