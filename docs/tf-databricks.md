┌─────────────────────────────────────────┐
│ TF can control the following resources: │
├─────────────────────────────────────────┤
│ ✓ Workspaces                            │
│ ✓ Clusters                              │
│ ✓ Jobs & Notebooks                      │
│ ✓ Service Principals (bot account)      │
│ ✓ Access Control                        │
│ ✓ Git Repos integration                 │
│ ✓ SQL Warehouses                        │
│ ✓ Secret Scopes (Password Management)   │
└─────────────────────────────────────────┘

Terraform CAN do:
✅ Auto Deploy - Create entire Databricks setup from 0
✅ Version Control - Saving Configuration in Git
✅ Create multiple environments - dev, test, prod with just code
✅ Backup - Rebuild workspace if deleted
✅ CI/CD Integration - Automatically deploy when commit

Terraform CANNOT do:
❌ Run Spark jobs (only Databricks runs, TF only manages)
❌ Data processing (using SQL/Python notebooks)
❌ Monitoring & logging

