# Terraform
My terraform project

## Usage

1. Login to the Azure portal

```bash
az login
```

2. Run tasks on the local first
```bash
# Get information from the script
source ./init/export-vars

# Verify you can access Azure
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

# Execute some terraform commands
terraform init
terraform validate
terraform plan -var-file ./env/dev/dev.tfvars -out plan.tfplan
terraform plan  -chdir=env/dev -out=gino.tfplan

terraform apply -var-file=./env/dev/dev.tfvars
```

3. Fix Key Vault Network Rules
```bash
# Allow GitHub-hosted runner IPs (GitHub publishes IP ranges)
az keyvault network-rule add \
  --resource-group <YOUR_RESOURCE_GROUP> \
  --name <YOUR_KEYVAULT_NAME> \
  --ip-address 13.83.0.0/16  # GitHub Actions IP range (check GitHub's published ranges)

# OR: Allow all Azure services
az keyvault update \
  --resource-group <YOUR_RESOURCE_GROUP> \
  --name <YOUR_KEYVAULT_NAME> \
  --bypass AzureServices \
  --default-action Deny
```

```bash
# Setup Azure OIDC cho GitHub Actions
az login

SUBSCRIPTION_ID="8d42870d-3e7a-48d8-8dcf-8b20ed4c5ad6"
TENANT_ID="995e9592-80c4-4aa3-b509-dd37e0571c05"
GITHUB_ORG="github.com"
GITHUB_REPO="terraform"

az ad sp create-for-rbac \
  --name "github-${GITHUB_REPO}" \
  --role "DevOps" \
  --scopes "/subscriptions/${SUBSCRIPTION_ID}"
```


terraform plan -chdir=env/dev -out=gino.tfplan

terraform -chdir=env/dev show gino.tfplan

terraform -chdir=env/dev apply
terraform -chdir=env/dev apply gino.tfplan
```