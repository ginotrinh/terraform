variable "resource_group_name" {
  type    = string
  default = "rg-databricks-demo"
}

variable "workspace_name" {
  type    = string
  default = "databricks-workspace"
}

variable "location" {
  type    = string
  default = "Southeast Asia"
}

variable "databricks_token" {
  type        = string
  sensitive   = true
  description = "Databricks personal access token by Gino"
}