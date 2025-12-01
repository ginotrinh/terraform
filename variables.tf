variable application_name {
  type        = string
  description = "The application name"
}

variable primary_location {
  type        = string
  default     = "Southeast Asia"
  description = "Azure primary region"
}

variable "environment_name" {
  type        = string
  description = "Environment name (dev, staging, prod)"
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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags"
}

# variable "subscription_id" {
#   type      = string
#   sensitive = true
# }
# variable "client_id" {
#   type      = string
#   sensitive = true
# }
# variable "client_secret" {
#   type      = string
#   sensitive = true
# }
# variable "tenant_id" {
#   type      = string
#   sensitive = true
# }