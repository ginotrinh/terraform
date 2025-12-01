resource "random_string" "keyvault_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Get current user/service principal info
data "azurerm_client_config" "current" {}

# Create Key Vault
resource "azurerm_key_vault" "main" {
  name                = "kv-${random_string.keyvault_suffix.result}-${var.environment_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Tenant ID
  tenant_id = data.azurerm_client_config.current.tenant_id

  # SKU
  sku_name  = "standard"

  # Soft Delete & Purge Protection
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = []
    ip_rules                   = [
      "119.82.134.131/32",
      "103.141.176.131/32",
      "103.199.7.5/32",
      "66.249.75.6"
    ]
  }

  # Extended timeouts to avoid error:
  # "Failure sending request: StatusCode=0 -- Original Error: context deadline exceeded"
  timeouts {
    create = "15m"
    read   = "10m"
    update = "15m"
    delete = "10m"
  }

  # Create tag name
  tags = merge(var.tags, {
    Name = "kv-${var.environment_name}"
  })
}

# Access Policy for current user/service principal
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.main.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
  #object_id = "fb1f43ec-7f16-4c79-a26f-63d0bfd3fae9"

  secret_permissions = ["Backup","Delete","Get","List","Purge","Recover","Restore","Set"]
  key_permissions = ["Backup","Create","Decrypt","Delete","Encrypt","Get","Import","List","Purge","Recover","Restore","Sign","UnwrapKey","Update","Verify","WrapKey"]

  #secret_permissions = ["get", "list", "set", "delete"]
  #key_permissions    = ["get", "list", "create", "delete"]
}

# resource "azurerm_databricks_workspace" "main" {
#   name                     = "db-st-${var.application_name}-${var.environment_name}"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   sku                      = "standard"
  
#   # Create tag name
#   tags = merge(var.tags, {
#     Name = "st-${var.application_name}-${var.environment_name}"
#   })
# #   tags = {
# #     environment = "staging"
# #   }
# }

# resource "databricks_service_principal" "main" {
#   display_name         = "dt-sp-${var.application_name}-${var.environment_name}"
#   allow_cluster_create = true
# }


# ====== READ SECRETS FROM KEY VAULT ======

# Read Client ID from Key Vault
resource "azurerm_key_vault_secret" "client_id" {
  name         = "azure-client-id"
  value        = var.azure_client_id
  key_vault_id = azurerm_key_vault.main.id
}

# Read Client Secret from Key Vault
resource "azurerm_key_vault_secret" "client_secret" {
  name         = "azure-client-secret"
  value        = var.azure_client_secret
  key_vault_id = azurerm_key_vault.main.id
}

# Read Tenant ID from Key Vault
resource "azurerm_key_vault_secret" "tenant_id" {
  name         = "azure-tenant-id"
  value        = var.azure_tenant_id
  key_vault_id = azurerm_key_vault.main.id
}

# Read Subscription ID from Key Vault
resource "azurerm_key_vault_secret" "subscription_id" {
  name         = "azure-subscription-id"
  value        = var.azure_subscription_id
  key_vault_id = azurerm_key_vault.main.id
}