# Terraform
My terraform project

## Usage

1. Login to the Azure portal

```bash
az login
```



```bash
terraform -chdir=env/dev init

terraform -chdir=env/dev validate

terraform -chdir=env/dev plan
terraform -chdir=env/dev plan -out=gino.tfplan

terraform -chdir=env/dev show gino.tfplan

terraform -chdir=env/dev apply
terraform -chdir=env/dev apply gino.tfplan
```