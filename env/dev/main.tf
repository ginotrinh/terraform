resource "azurerm_resource_group" "this" {
  name     = "gino-rg-dtb-tf"
  location = "Southeast Asia"
}

resource "azurerm_databricks_workspace" "this" {
  name                = "databricks-workspace"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "standard"
}

resource "databricks_service_principal" "terraform" {
  display_name         = "gino-tf-auto"
  allow_cluster_create = true
}