terraform {
  backend "azurerm" {
    resource_group_name  = "rg-azure-githubactions"
    storage_account_name = "saazuregithubactions"
    container_name       = "azure-githubactions-development"
    key                  = "terraform.tfstate"
  }
}