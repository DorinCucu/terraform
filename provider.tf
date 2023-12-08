terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0"
    }
  }
  backend "azurerm" {
    subscription_id      = "9eaf95a4-1661-4620-bcda-48cdf01fa896"
    resource_group_name  = "terraform"
    storage_account_name = "terraformstateproj"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }
}
 
provider "azurerm" {
  features {}
}