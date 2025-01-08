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
    "enviroment" = "Dev"
  }
}

/* Virtual Network */
resource "azurerm_virtual_network" "my_vn" {
  name                = "my_network"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  address_space       = ["172.16.0.0/16"]

  tags = {
    environment = "Dev"
  }
}

/* Subnet */
resource "azurerm_subnet" "my_subnet" {
  name                 = "my_subnet"
  resource_group_name  = azurerm_resource_group.my_rg.name
  virtual_network_name = azurerm_virtual_network.my_vn.name
  address_prefixes     = ["172.16.1.0/24"]
}

/* Network Security Group */
resource "azurerm_network_security_group" "my_nsg" {
  name                = "my_nsg"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name


  tags = {
    environment = "Dev"
  }
}