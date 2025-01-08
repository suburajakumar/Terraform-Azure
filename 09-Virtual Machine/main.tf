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
  location = "East US 2"

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

/* Public IP Creation */
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
    public_ip_address_id          = azurerm_public_ip.my_pip.id
  }
}

/* Virtual machine */
resource "azurerm_linux_virtual_machine" "my_vm" {
  name                  = "my-machine"
  resource_group_name   = azurerm_resource_group.my_rg.name
  location              = azurerm_resource_group.my_rg.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.my_ni.id]
  
  /* Passing Key */
  admin_ssh_key {
    username   = "adminuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCQH+/OB/Vc50gYyetVVLzb+N47RRStswogUvZSAw8/7ZhE6zxORlH221I9Lb4huSs7OlCAg865MIXIllNxFI2D4gmFA8WgeGhT6eNTd03LLp7a74uFv0rRMq5f2QMrNJB84uxDenS2ET5rquLFLGJAP3/Lzw+mcIUu9demxN7xi8bkEQcyiHb8zQUPpIo52IISYEUeILmTSn3uOa7R7SC6Cv8WEV3bNE/0Km4GmlNCT9zeXT7Pu0ViMz6UvTpjAQLs6OJQOtuUfmdrlYohaTBBtw4wpqRO48pwQ8oce1d1J3OhAkRUoJ/HXiQzDy0jU6LwtBHsAOfHpRlOf+MfQ1ch rsa-key-20221111"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
