# Terraform
My terraform project

## Usage

1. Login to the Azure portal

```bash
az login
```

```bash
# Get information from the script
source ./init/export-vars

# Verify you can access Azure
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

# Execute some terraform commands
terraform init
terraform validate
terraform plan  -var-file=./env/dev/dev.tfvars
terraform apply -var-file=./env/dev/dev.tfvars
```

```bash
# Setup Azure OIDC cho GitHub Actions
az login

SUBSCRIPTION_ID="8d42870d-3e7a-48d8-8dcf-8b20ed4c5ad6"
TENANT_ID="995e9592-80c4-4aa3-b509-dd37e0571c05"
GITHUB_ORG="your-github-org"
GITHUB_REPO="your-repo-name"
```


terraform plan -chdir=env/dev -out=gino.tfplan

terraform -chdir=env/dev show gino.tfplan

terraform -chdir=env/dev apply
terraform -chdir=env/dev apply gino.tfplan
```