# Azure Terraform Setup - Detailed Configuration Guide

## Part 1: Backend Configuration (env/dev/backend.tf)

### What is a Terraform Backend?

A backend is where Terraform stores its **state file** - a JSON file that tracks all resources you've created. This state file is critical because:
- It maps your infrastructure code to actual Azure resources
- It enables team collaboration (shared state vs local state)
- It prevents accidental resource duplication
- It tracks resource dependencies

**Without remote backend**: State stored locally (not suitable for teams)
**With remote backend**: State stored in Azure Storage Account (team-friendly, secure, versioned)

### File: env/dev/backend.tf

```hcl
# Configure Terraform to store state in Azure Storage Account
# This allows team members to collaborate and prevents state conflicts

terraform {
  backend "azurerm" {
    # Storage account name where state files are stored
    storage_account_name = "dataprocessingtfstate"
    
    # Resource group containing the storage account
    resource_group_name = "data-processing-rg"
    
    # Container inside the storage account
    container_name = "tfstate"
    
    # Unique state file name for this environment
    # Each environment gets its own state file to prevent conflicts
    key = "dev.terraform.tfstate"
  }
}
```

### Why Each Environment Needs Separate Keys?

```
Azure Storage Account: dataprocessingtfstate
├── Container: tfstate
    ├── dev.terraform.tfstate       ← Development infrastructure state
    ├── uat.terraform.tfstate       ← UAT infrastructure state
    └── prod.terraform.tfstate      ← Production infrastructure state
```

**Benefits:**
- ✅ Dev changes don't affect UAT or Prod
- ✅ Easy rollback per environment
- ✅ Different state versions can be maintained
- ✅ Clear separation of concerns

---

## Part 2: Provider Configuration (env/dev/providers.tf)

### What is a Provider?

A provider is a plugin that tells Terraform how to interact with Azure. It handles:
- Authentication to Azure
- Creating, updating, and deleting resources
- Managing resource lifecycles

### File: env/dev/providers.tf

```hcl
# Define which Terraform version is required
terraform {
  required_version = ">= 1.5.0"
  
  # Define required providers and their versions
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"  # ~> means >= 3.100.0 but < 4.0.0
    }
  }
}

# Configure the Azure Provider
# This provider handles all Azure-related operations
provider "azurerm" {
  features {
    # Key vault soft-delete protection
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    
    # Virtual machine features
    virtual_machine {
      delete_os_disk_on_deletion            = true
      graceful_shutdown                     = true
      skip_shutdown_and_force_delete        = false
    }
  }
  
  # Use environment variables for authentication
  # Set via: az login or service principal
  # This avoids hardcoding credentials
}

# Optional: Define locals for common values used across this environment
locals {
  environment = "dev"
  location    = "eastus"
  project     = "data-processing"
  
  # Standard tags applied to ALL resources in this environment
  # Ensures consistent tagging across infrastructure
  common_tags = {
    Environment  = local.environment
    Project      = local.project
    ManagedBy    = "Terraform"
    CreatedDate  = timestamp()
    Owner        = "data-team"
    CostCenter   = "CC-001"
  }
}
```

### Authentication Methods

**Option 1: Azure CLI (Development)**
```bash
az login
# Terraform automatically uses your logged-in account
```

**Option 2: Service Principal (CI/CD)**
```bash
export ARM_CLIENT_ID="<client-id>"
export ARM_CLIENT_SECRET="<client-secret>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"
```

**Option 3: Managed Identity (Azure VMs/Azure DevOps)**
```bash
export ARM_USE_MSI=true
export ARM_SUBSCRIPTION_ID="<subscription-id>"
```

---

## Part 3: Variables Configuration (env/dev/variables.tf)

### What are Variables?

Variables allow you to parameterize your infrastructure code. Instead of hardcoding values, you define variables that can be:
- Set via `terraform.tfvars` files
- Overridden via CLI
- Shared across environments with different values

### File: env/dev/variables.tf

```hcl
# Environment name - identifies which stage this is
variable "environment" {
  description = "Environment name (dev, uat, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment must be dev, uat, or prod."
  }
}

# Azure region/location for resource deployment
variable "location" {
  description = "Azure region for resources (e.g., eastus, westus2)"
  type        = string
  
  validation {
    condition     = length(var.location) > 0
    error_message = "Location cannot be empty."
  }
}

# Project identifier - used in resource naming
variable "project_name" {
  description = "Project identifier for naming conventions"
  type        = string
  
  validation {
    condition     = length(var.project_name) <= 20 && can(regex("^[a-z0-9-]*$", var.project_name))
    error_message = "Project name must be lowercase alphanumeric with hyphens, max 20 chars."
  }
}

# Resource Group configuration
variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  
  validation {
    condition     = length(var.resource_group_name) <= 90
    error_message = "Resource Group name must be max 90 characters."
  }
}

# Virtual Network configuration
variable "vnet_address_space" {
  description = "Address space for Virtual Network (CIDR notation)"
  type        = list(string)
  default     = ["10.0.0.0/16"]
  
  validation {
    condition     = length(var.vnet_address_space) > 0
    error_message = "Virtual Network address space cannot be empty."
  }
}

# Subnet configuration
variable "subnet_address_prefix" {
  description = "Address prefix for subnet (CIDR notation)"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

# Storage account configuration
variable "storage_account_name" {
  description = "Name of the Storage Account (must be globally unique, lowercase, alphanumeric)"
  type        = string
  
  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24 && can(regex("^[a-z0-9]*$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}

# Storage account tier (Standard or Premium)
variable "storage_account_tier" {
  description = "Storage Account performance tier"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage tier must be Standard or Premium."
  }
}

# Storage account replication type
variable "storage_replication_type" {
  description = "Storage Account replication type (LRS, GRS, RA-GRS, ZRS)"
  type        = string
  default     = "LRS"  # Locally Redundant Storage for dev/uat
  
  validation {
    condition     = contains(["LRS", "GRS", "RA-GRS", "ZRS", "GZRS", "RA-GZRS"], var.storage_replication_type)
    error_message = "Invalid replication type."
  }
}

# Custom tags for all resources
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
  
  example = {
    Compliance = "SOC2"
    Team       = "DataEngineering"
  }
}

# Data processing configuration
variable "data_processing_config" {
  description = "Configuration for data processing components"
  type = object({
    enable_databricks    = bool
    enable_data_factory  = bool
    enable_synapse       = bool
    instance_count       = number
  })
  
  default = {
    enable_databricks   = true
    enable_data_factory = true
    enable_synapse      = false
    instance_count      = 1
  }
  
  validation {
    condition     = var.data_processing_config.instance_count > 0 && var.data_processing_config.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}
```

---

## Part 4: Terraform Values (env/dev/terraform.tfvars)

### What is terraform.tfvars?

This file sets **actual values** for the variables you defined in `variables.tf`. It's environment-specific.

### File: env/dev/terraform.tfvars

```hcl
# Development Environment Configuration

# Environment designation
environment = "dev"

# Azure region - using East US for dev
location = "eastus"

# Project identifier
project_name = "data-processing"

# Resource Group - dev-specific naming
resource_group_name = "data-processing-dev-rg"

# Virtual Network configuration for dev
vnet_address_space = ["10.0.0.0/16"]

# Subnet configuration for dev
subnet_address_prefix = ["10.0.1.0/24"]

# Storage Account - must be globally unique
# Format: {project}{environment}storage{random}
storage_account_name = "dataprocessingdevstorage001"

# Dev uses Standard tier (cheaper than Premium)
storage_account_tier = "Standard"

# Dev uses LRS (locally redundant, sufficient for non-critical data)
storage_replication_type = "LRS"

# Development-specific features
data_processing_config = {
  enable_databricks   = true    # Enable for development/testing
  enable_data_factory = true
  enable_synapse      = false   # Not needed in dev
  instance_count      = 1       # Minimal resources in dev
}

# Additional environment-specific tags
additional_tags = {
  Environment = "Development"
  CostCenter  = "CC-0001-DEV"
  Owner       = "data-team"
  Compliance  = "None"
}
```

### Comparison Across Environments

```hcl
# ========== env/uat/terraform.tfvars ==========
environment                = "uat"
location                   = "eastus"
project_name               = "data-processing"
resource_group_name        = "data-processing-uat-rg"
vnet_address_space         = ["10.1.0.0/16"]          # Different CIDR
subnet_address_prefix      = ["10.1.1.0/24"]
storage_account_name       = "dataprocessinguatstorage001"
storage_account_tier       = "Standard"
storage_replication_type   = "LRS"
data_processing_config = {
  enable_databricks   = true
  enable_data_factory = true
  enable_synapse      = true    # Enabled for full testing
  instance_count      = 2       # More resources for testing
}

# ========== env/prod/terraform.tfvars ==========
environment                = "prod"
location                   = "eastus"
project_name               = "data-processing"
resource_group_name        = "data-processing-prod-rg"
vnet_address_space         = ["10.2.0.0/16"]          # Different CIDR
subnet_address_prefix      = ["10.2.1.0/24"]
storage_account_name       = "dataprocessingprodstorage001"
storage_account_tier       = "Premium"                # Higher tier for production
storage_replication_type   = "GRS"                    # Geo-redundant for production
data_processing_config = {
  enable_databricks   = true
  enable_data_factory = true
  enable_synapse      = true
  instance_count      = 5       # Full capacity for production
}
```

---

## Part 5: Sample Module - Storage Module

### What is a Module?

A module is a reusable collection of Terraform files that encapsulates a specific piece of infrastructure. Benefits:
- Reusability across environments
- Abstraction of complexity
- Version control
- Team collaboration

### File: modules/storage/main.tf

```hcl
# Create Azure Resource Group (if not already existing)
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Create Azure Storage Account
resource "azurerm_storage_account" "storage" {
  # Resource identifier must be globally unique
  name                     = var.storage_account_name
  
  # Associate with resource group
  resource_group_name      = azurerm_resource_group.rg.name
  
  # Deployment region
  location                 = azurerm_resource_group.rg.location
  
  # Performance tier: Standard (general purpose) or Premium (specialized)
  account_tier             = var.storage_account_tier
  
  # Replication strategy (LRS = local redundancy, GRS = geo redundancy)
  account_replication_type = var.storage_replication_type
  
  # Enforce HTTPS-only connections
  https_traffic_only_enabled = true
  
  # Default to Azure services having access
  shared_access_key_enabled = true
  
  # Enable soft delete for accidental deletion recovery
  blob_properties {
    delete_retention_policy {
      days = 7  # Recover deleted blobs within 7 days
    }
    container_delete_retention_policy {
      days = 7
    }
  }
  
  # Apply consistent tags to track cost and ownership
  tags = var.tags
}

# Create Blob Container for data storage
resource "azurerm_storage_container" "blob_container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage.name
  
  # Access level: Private = no public access
  container_access_type = "private"
}

# Optional: Create second container for backup/archive
resource "azurerm_storage_container" "backup_container" {
  count                 = var.enable_backup_container ? 1 : 0
  name                  = "${var.container_name}-backup"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Optional: Configure lifecycle policies for cost optimization
resource "azurerm_storage_management_policy" "lifecycle" {
  count              = var.enable_lifecycle_policy ? 1 : 0
  storage_account_id = azurerm_storage_account.storage.id

  rule {
    name    = "archive-old-data"
    enabled = true
    
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["data/"]
    }

    actions {
      # Move to Cool tier after 30 days of no access
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 30
      }
      # Delete after 365 days
      delete {
        delete_after_days_since_modification_greater_than = 365
      }
    }
  }
}
```

### File: modules/storage/variables.tf

```hcl
# Storage account configuration variables

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the Storage Account (globally unique, 3-24 chars)"
  type        = string
  
  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24
    error_message = "Storage account name must be 3-24 characters."
  }
}

variable "storage_account_tier" {
  description = "Storage Account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Must be Standard or Premium."
  }
}

variable "storage_replication_type" {
  description = "Replication type (LRS, GRS, RA-GRS, ZRS)"
  type        = string
  default     = "LRS"
}

variable "container_name" {
  description = "Name of the Blob Container"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]*$", var.container_name))
    error_message = "Container name must be lowercase alphanumeric and hyphens."
  }
}

variable "enable_backup_container" {
  description = "Create additional backup container"
  type        = bool
  default     = false
}

variable "enable_lifecycle_policy" {
  description = "Enable lifecycle policies for data tiering"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
```

### File: modules/storage/outputs.tf

```hcl
# Export values from this module for use by other modules or environments

output "storage_account_id" {
  description = "The ID of the Storage Account"
  value       = azurerm_storage_account.storage.id
}

output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = azurerm_storage_account.storage.name
}

output "primary_blob_endpoint" {
  description = "The endpoint URL of the primary Blob Storage"
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}

output "container_id" {
  description = "The ID of the Blob Container"
  value       = azurerm_storage_container.blob_container.id
}

output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = azurerm_resource_group.rg.name
}

output "backup_container_id" {
  description = "The ID of the backup Blob Container (if created)"
  value       = var.enable_backup_container ? azurerm_storage_container.backup_container[0].id : null
}
```

---

## Part 6: Wiring Module into Environment (env/dev/main.tf)

### File: env/dev/main.tf

```hcl
# Import locals from providers.tf
locals {
  environment = "dev"
  location    = "eastus"
  project     = "data-processing"
  
  common_tags = {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "Terraform"
    Owner       = "data-team"
    CostCenter  = "CC-0001"
  }
}

# Merge common tags with additional tags from variables
locals {
  merged_tags = merge(
    local.common_tags,
    var.additional_tags
  )
}

# CALL THE STORAGE MODULE
# This creates all the storage-related infrastructure
module "storage" {
  source = "../../modules/storage"  # Relative path to storage module
  
  # Pass variables to the module
  resource_group_name     = var.resource_group_name
  location                = var.location
  storage_account_name    = var.storage_account_name
  storage_account_tier    = var.storage_account_tier
  storage_replication_type = var.storage_replication_type
  
  # Container configuration
  container_name           = "data-raw"  # Where raw data lands
  enable_backup_container  = true        # Enable backup container
  enable_lifecycle_policy  = true        # Enable tiering policy
  
  # Pass tags to the module
  tags = local.merged_tags
}

# Example: Create additional containers for different data stages
module "storage_processed" {
  source = "../../modules/storage"
  
  resource_group_name      = var.resource_group_name
  location                 = var.location
  storage_account_name     = "${var.storage_account_name}-processed"
  storage_account_tier     = var.storage_account_tier
  storage_replication_type = var.storage_replication_type
  
  container_name           = "data-processed"
  enable_backup_container  = false
  enable_lifecycle_policy  = true
  
  tags = local.merged_tags
  
  # Ensure this storage account is created after the first one
  depends_on = [module.storage]
}
```

---

## Part 7: Output Values (env/dev/outputs.tf)

### File: env/dev/outputs.tf

```hcl
# Export infrastructure details for reference, automation, or other modules

output "storage_account_name" {
  description = "Name of the created Storage Account"
  value       = module.storage.storage_account_name
}

output "storage_primary_endpoint" {
  description = "Primary Blob endpoint of Storage Account"
  value       = module.storage.primary_blob_endpoint
}

output "resource_group_name" {
  description = "Name of the created Resource Group"
  value       = module.storage.resource_group_name
}

output "raw_data_container_id" {
  description = "ID of the raw data blob container"
  value       = module.storage.container_id
}

output "processed_data_container_id" {
  description = "ID of the processed data blob container"
  value       = module.storage_processed.container_id
}
```

---

## Complete Deployment Workflow

### Step 1: Initialize Terraform
```bash
cd env/dev
terraform init
```

### Step 2: Validate Configuration
```bash
terraform validate
terraform fmt -recursive
```

### Step 3: Plan Deployment
```bash
terraform plan -out=tfplan
```

### Step 4: Review & Apply
```bash
terraform apply tfplan
```

### Step 5: Verify Resources
```bash
terraform output
terraform state list
terraform state show module.storage.azurerm_storage_account.storage
```

---

## Key Concepts Summary

| Component | Purpose | Example |
|-----------|---------|---------|
| **backend.tf** | Stores state in Azure Storage | Remote, versioned, team-friendly |
| **providers.tf** | Authenticates with Azure | Required plugins and authentication |
| **variables.tf** | Define input parameters | Reusable across environments |
| **terraform.tfvars** | Set actual values | Environment-specific configuration |
| **modules/** | Reusable infrastructure | Storage, networking, compute |
| **main.tf** | Call modules & create resources | Orchestrates infrastructure |
| **outputs.tf** | Export values for reference | Share data between modules |

---

## Common Commands Reference

```bash
# Initialize (download providers, set up backend)
terraform init

# Validate syntax
terraform validate

# Format code to standards
terraform fmt -recursive

# Show planned changes
terraform plan

# Show planned changes with detail
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Show current state
terraform state list
terraform state show module.storage.azurerm_storage_account.storage

# Destroy infrastructure (dev only!)
terraform destroy

# Show outputs
terraform output

# Workspace management (alternative to separate state files)
terraform workspace list
terraform workspace select uat
```

---

## Security Best Practices

✅ **Do This:**
- Store sensitive values in Azure Key Vault
- Use managed identities instead of service principals when possible
- Enable backend encryption and versioning
- Use private endpoints for storage access
- Enable diagnostic logging for all resources
- Validate all user inputs with `validation` blocks

❌ **Don't Do This:**
- Never commit `.tfvars` files with secrets to Git
- Don't use `hardcoded credentials`
- Don't make state files public
- Don't skip validation blocks
- Don't apply production changes without approval

