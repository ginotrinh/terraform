# Description

Initialize repo with structure, documentation, and base configuration.

# Key Deliverables

[x] 1. New github repo, basic folder structure

```
docs
env/
    dev
    uat
    prod
modules
    compute
    data-processing
    networking
    storage
README.md
```

[x] 2. Branching strategy and protection rules:

-   Environment Branching:
    -   main: production line, code is always good & stable. This is only be merged from another one when review is passed, CI/CD.
    -   dev: for developing & testing purposes.
    -   uta: for staging.
    -   feature/*: The separate branch for features/extension. This branch will be merged to `dev/main`.
    -   hotfix/*: Hotfix branches for urgent fixes.

```text
infrastructure/
├── env/
│   ├── dev/
│   ├── uta/
│   └── prod/
├── modules/
└── README.md
```

-   Branching Management:
    -   Only deploy in an environment when merging to the appropriate branch:
        -   Merge into `main` -> CI/CD apply on prod.
        -   Merge into `dev` -> apply on dev.
    -   Feature branch (feature/add-db, bugfix/fix-bucket) is only for editing/fixing feature, it is not allowed for directly application.
    -   Pull Request/Merge Request must be audited, review & pass CI (terraform fmt, validate, plan)
    
-   Branch Protection Rules:
    - Rules for Production environment (`main`):
        -   Require Pull Request before merge: pushing directly is not allowed, a PR needs to be created and reviewed.
        -   Require status checks to pass before merging: Pass CI from `terraform validate`, `terraform plan` with zero-error.
        -   Require specific reviewers: At least 1-2 reviewers (valid code owner)
        -   Require signed commits: Prevent invalid commitments, history access.
        -   Restrict who can push to matching branches: Only CI/CD bot or admin has the push/merge permission.
        -   Restrict force-push: Prevent forcing push to delete or overwrite the history.
        -   Restrict deletion: Prevent directly deleting the branch.

[x] 3. Naming convention document, tagging standards

-   Naming Convention
    -   Resource Naming
        -   Format: `{project}-{resource-type}-{environment}-{unique}`
        -   Examples:
            -   data-processing-vnet-dev-001
            -   data-processing-storage-uat-001
            -   data-processing-aks-prod-001
    -   Resource Group Naming
        -   Format: `{project}-{environment}-rg`
        -   Examples:
            -   data-processing-dev-rg
            -   data-processing-uat-rg
            -   data-processing-prod-rg
    -   Storage Account Naming
        -   Format: `{project}{environment}storage`
        -   Examples:
            -   dataprocessingdevstorage
            -   dataprocessinguatstorage
            -   dataprocessingprodstorage

- Standard Tagging:
    **Required Tags**
    -   `Environment`: dev, uat, prod
    -   `Project`: data-processing
    -   `Owner`: team name or individual
    -   `CostCenter`: department code
    -   `Application`: application name
    -   `ManagedBy`: terraform
-   Example Tag Block
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

[x] 4. Terraform Backend Block with Storage Account, Blob Container (tfstate)

-   Use AZ Blob Storage service to store Terraform state. Components:
    -   **Resource Group**: logic container for resources.
    -   **Storage Account**: store account.
    -   **Blob Container**: a container containing state files.
    -   **State File**: terraform state file named `terraform.tfstate` (binary)
    
-   Action: a shell script is provided to do the followingh tasks:
    -   Create a resource group.
    -   Create a storage account.
    -   Obtain the storage account key.
    -   Create the blob container using storage account's key.
    -   Enable soft delete mode (recovery).
    -   (Optional) print the result to the console.


