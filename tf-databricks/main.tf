# Create Resource Group
resource "azurerm_resource_group" "this" {
  name     = "rg-databricks-demo"
  location = "Southeast Asia"
}

# Create Databricks Workspace on Azure
resource "azurerm_databricks_workspace" "this" {
  name                = "databricks-workspace"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "standard" # supported values: standard, premium, trial

  depends_on = [azurerm_resource_group.this]
}

# Configure Databricks provider (obtain info from workspace)
# provider "databricks" {
#   host = azurerm_databricks_workspace.this.workspace_url
  
#   # Terraform will automatically use your Azure CLI token
#   # (you have to run `az login` first)
# }

provider "databricks" {
  host  = azurerm_databricks_workspace.this.workspace_url
  token = var.databricks_token  # Sẽ được cung cấp từ biến môi trường
}
