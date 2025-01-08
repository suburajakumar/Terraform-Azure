terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}
provider "azurerm" {
  features {}
}

resource "random_id" "random" {
  byte_length = 2
}

resource "azurerm_resource_group" "sa-rg" {
  name     = "storageaccount"
  location = "eastus"
}

resource "azurerm_storage_account" "my_sa" {
  name                     = "mystorageaccount${random_id.random.dec}"
  resource_group_name      = azurerm_resource_group.sa-rg.name
  location                 = azurerm_resource_group.sa-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "Blob" {
  name                  = "raja"
  storage_account_name  = azurerm_storage_account.my_sa.name
  container_access_type = "private"
}

resource "azurerm_storage_queue" "Queue" {
  name                 = "raja"
  storage_account_name = azurerm_storage_account.my_sa.name
}