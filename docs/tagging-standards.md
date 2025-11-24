# Tagging Standards

**Required Tags**
    -   `Environment`: dev, uat, prod
    -   `Project`: data-processing
    -   `Owner`: team name or individual
    -   `CostCenter`: department code
    -   `Application`: application name
    -   `ManagedBy`: terraform

Example Tag Block
```hcl
text
locals {
  tags = {
    Environment  = var.environment
    Project      = "data-processing"
    Owner        = "data-team"
    CostCenter   = "CC123"
    Application  = "data-pipeline"
    ManagedBy    = "terraform"
  }
}
```

