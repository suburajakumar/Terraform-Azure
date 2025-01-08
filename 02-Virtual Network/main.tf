# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group Creation
resource "azurerm_resource_group" "my_rg" {
  name     = "my_rg"
  location = "East US"
  
  tags = {
    "enviroment" = "Test"
  }
}

/* Virtual Network  */
resource "azurerm_virtual_network" "my_vn" {
  name                = "my_network"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  address_space       = ["172.16.0.0/16"]

  tags = {
    environment = "Test"
  }
}