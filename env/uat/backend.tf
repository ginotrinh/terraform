terraform {
	backend "azurerm" {
		resource_group_name  = "gino-rg-tf-backend"
		storage_account_name = "tfstate1764145743"
		container_name       = "tfstate"
		key                  = "uat/uat.terraform.tfstate"
	}
}