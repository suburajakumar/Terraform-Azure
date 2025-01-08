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

resource "azuread_user" "example" {
  user_principal_name = "kali@raja-net.in"
  display_name        = "Kali"
  mail_nickname       = "Kalram"
  password            = "SecretP@sswd99!"
}

resource "azuread_group" "group" {
  display_name     = "raja"
  security_enabled = true
}

resource "azuread_group_member" "example" {
  group_object_id  = azuread_group.group.id
  member_object_id = azuread_user.example.id
}