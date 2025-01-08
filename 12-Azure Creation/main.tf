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


resource "azuread_user" "new_user" {
  user_principal_name = "raja002@rajacloud002gmail.onmicrosoft.com"
  display_name        = "Raja"
  mail_nickname       = "raja"
  password            = "SecretP@sswd99!"
}

resource "azuread_directory_role" "role" {
  display_name = "Security administrator"
}

resource "azuread_directory_role_assignment" "role_assign" {
  role_id             = azuread_directory_role.role.template_id
  principal_object_id = azuread_user.new_user.object_id
}