# Add a dependency for the Databricks Terraform provider.
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }

  # Use environment variables or variables from GitHub
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

# provider "databricks" {
#   host                        = azurerm_databricks_workspace.main.workspace_url
#   azure_workspace_resource_id = azurerm_databricks_workspace.main.id
#   azure_client_id             = var.client_id
#   azure_client_secret         = var.client_secret
#   azure_tenant_id             = var.tenant_id
# }