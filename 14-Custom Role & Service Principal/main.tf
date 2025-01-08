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

data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "test" {}

resource "azurerm_role_definition" "test" {
  //role_definition_id = "00000000-0000-0000-0000-000000000000"
  name               = "my-custom-role-definition"
  scope              = "${data.azurerm_subscription.primary.id}"

  permissions {
    actions     = ["Microsoft.Resources/subscriptions/resourceGroups/read"]
    not_actions = []
  }

  assignable_scopes = [
    "${data.azurerm_subscription.primary.id}",
  ]
}

/*resource "azurerm_role_assignment" "test" {
  name               = "00000000-0000-0000-0000-000000000000"
  scope              = "${data.azurerm_subscription.primary.id}"
  role_definition_id = "${azurerm_role_definition.test.id}"
  principal_id       = "${data.azurerm_client_config.test.service_principal_object_id}"
}*/