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
  location = "Central India"
  tags = {
    "enviroment" = "Test"
  }
}