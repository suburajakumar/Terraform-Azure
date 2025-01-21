variable "resource_group_name" {
  default = "Vnet-peerning"
}

variable "location" {
  default = "eastus"
}

variable "vnet_config" {
  default = [
    { name = "VNet1", address_space = "10.0.0.0/16", subnet_prefix = "10.0.1.0/24" },
    { name = "VNet2", address_space = "10.1.0.0/16", subnet_prefix = "10.1.1.0/24" }
  ]
}