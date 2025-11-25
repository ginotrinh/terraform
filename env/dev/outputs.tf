output "databricks_workspace_url" {
  value = azurerm_databricks_workspace.this.workspace_url
}

output "service_principal_id" {
  value = databricks_service_principal.terraform.id
  sensitive = true
}