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

resource "azurerm_resource_group" "raja" {
  name     = "raja-resource-group"
  location = "East US"
}

resource "random_integer" "ri" {
  min = 10000
  max = 99895
}

resource "azurerm_cosmosdb_account" "db" {
  name                = "raja-cosmos-db-${random_integer.ri.result}"
  location            = azurerm_resource_group.raja.location
  resource_group_name = azurerm_resource_group.raja.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = "eastus"
    failover_priority = 1
  }

  geo_location {
    location          = "westus"
    failover_priority = 0
  }
}