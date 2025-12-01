# output "databricks_workspace_url" {
#   value = azurerm_databricks_workspace.main.workspace_url
# }

# output "service_principal_id" {
#   value     = databricks_service_principal.terraform.id
#   sensitive = true
# }

output "key_vault_id" {
  value       = azurerm_key_vault.main.id
  description = "The ID of the Azure Key Vault"
}

output "key_vault_name" {
  value       = azurerm_key_vault.main.name
  description = "The name of the Azure Key Vault"
}

output "key_vault_uri" {
  value       = azurerm_key_vault.main.vault_uri
  description = "The URI of the Azure Key Vault"
}