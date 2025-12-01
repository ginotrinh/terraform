variable "application_name" {
  type        = string
  description = "The application name"
}

variable "environment_name" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "primary_location" {
  type        = string
  default     = "Southeast Asia"
  description = "Azure primary region"
}

variable "azure_subscription_id" {
  type        = string
  sensitive   = true
  description = "Azure Subscription ID"
}

variable "azure_tenant_id" {
  type        = string
  sensitive   = true
  description = "Azure Tenant ID"
}

variable "azure_client_id" {
  type        = string
  sensitive   = true
  description = "Azure Service Principal Client ID"
}

variable "azure_client_secret" {
  type        = string
  sensitive   = true
  description = "Azure Service Principal Client Secret"
}

variable "key_vault_name" {
  type        = string
  description = "Azure Key Vault name"
}

variable "databricks_sku" {
  type        = string
  default     = "STANDARD"
  description = "Databricks SKU"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common Tags"
}