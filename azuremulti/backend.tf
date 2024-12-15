terraform {
  backend "azurerm" {
    resource_group_name  = "manualtest"
    storage_account_name = "tfstatetest1"
    container_name       = "tfstatetest"
    key                  = "test.terraform.tfstate"
  }
}