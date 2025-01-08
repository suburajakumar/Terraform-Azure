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

/* NSG Rule */
resource "azurerm_network_security_rule" "my_dev_rule" {
  name                        = "my_dev_rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.my_rg.name
  network_security_group_name = azurerm_network_security_group.my_nsg.name
}

/* NSG association with subnet */
resource "azurerm_subnet_network_security_group_association" "mg_nsg_asso" {
  subnet_id                 = azurerm_subnet.my_subnet.id
  network_security_group_id = azurerm_network_security_group.my_nsg.id
}

/* Public IP */
resource "azurerm_public_ip" "my_pip" {
  name                = "My_publicIP"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Dev"
  }
}

/* Network Interface */
resource "azurerm_network_interface" "my_ni" {
  name                = "my-nic"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}