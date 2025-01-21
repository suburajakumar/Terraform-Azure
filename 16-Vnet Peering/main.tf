provider "azurerm" {
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create VNets and Subnets
resource "azurerm_virtual_network" "vnet" {
  count              = length(var.vnet_config)
  name               = var.vnet_config[count.index].name
  address_space      = [var.vnet_config[count.index].address_space]
  location           = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  count                = length(var.vnet_config)
  name                 = "Subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[count.index].name
  address_prefixes     = [var.vnet_config[count.index].subnet_prefix]
}

# Create Public IP Addresses
resource "azurerm_public_ip" "public_ip" {
  count               = length(var.vnet_config)
  name                = "testvm-public-ip-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Set Up Peering
resource "azurerm_virtual_network_peering" "vnet_peering" {
  count = length(var.vnet_config) - 1
  
  name                       = "${azurerm_virtual_network.vnet[count.index].name}-to-${azurerm_virtual_network.vnet[count.index + 1].name}"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_network_name       = azurerm_virtual_network.vnet[count.index].name
  remote_virtual_network_id  = azurerm_virtual_network.vnet[count.index + 1].id
  allow_virtual_network_access = true
}

# Create Network Interfaces
resource "azurerm_network_interface" "nic" {
  count               = length(var.vnet_config)
  name                = "testvm-nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "testvm-ip-config"
    subnet_id                     = azurerm_subnet.subnet[count.index].id
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create Test VMs
resource "azurerm_virtual_machine" "vm" {
  count               = length(var.vnet_config)
  name                = "testvm-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  vm_size             = "Standard_B1s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "testvm-${count.index}"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}