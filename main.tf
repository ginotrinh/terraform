# ====== CREATE RESOURCE GROUP WORKSPACE ======
resource "azurerm_resource_group" "rg" {
  #name     = "rg-dtb-tf"
  name     = "rg-kv-${var.application_name}-${var.environment_name}"
  location = var.primary_location
  #location = "Southeast Asia"

  # Create tag name
  tags = merge(var.tags, {
    Name = "rg-kv-${var.environment_name}"
  })
}

# ====== CREATE DATABRICKS WORKSPACE ======
resource "azurerm_resource_group" "databricks" {
  name     = "rg-${var.environment_name}-databricks"
  location = var.primary_location

  tags = merge(var.tags, {
    Name = "rg-${var.environment_name}-databricks"
  })
}

resource "azurerm_databricks_workspace" "main" {
  name                = "dbws-${var.application_name}-${var.environment_name}"
  resource_group_name = azurerm_resource_group.databricks.name
  location            = azurerm_resource_group.databricks.location
  sku                 = var.databricks_sku

  tags = merge(var.tags, {
    Name = "dbws-${var.application_name}-${var.environment_name}"
  })
}