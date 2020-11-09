# Hub-Spoke VNET 
resource "azurerm_virtual_network" "hub" {
    name                        = var.hub_vnet_name
    location                    = var.location 
    resource_group_name         = var.resource_group_name
    address_space               = [var.hub_vnet_addr_prefix]
    tags                        = var.tags
}

# Spoke VNET 
resource "azurerm_virtual_network" "spoke" {
    name                        = var.spoke_vnet_name
    location                    = var.location 
    resource_group_name         = var.resource_group_name
    address_space               = [var.spoke_vnet_addr_prefix]
    tags                        = var.tags
}

# Hub-Spoke Peering
resource "azurerm_virtual_network_peering" "hub_spoke_peering" {
    name                        = "hub_spoke_peer"
    resource_group_name         = var.resource_group_name
    virtual_network_name        = azurerm_virtual_network.hub.name 
    remote_virtual_network_id   = azurerm_virtual_network.spoke.id 
}

resource "azurerm_virtual_network_peering" "spoke_hub_peering" {
    name                        = "spoke_hub_peer"
    resource_group_name         = var.resource_group_name
    virtual_network_name        = azurerm_virtual_network.spoke.name 
    remote_virtual_network_id   = azurerm_virtual_network.hub.id 
}

# Azure Firewall 
module "azure_firewall" { 
    source                      = "../azure_firewall"
    resource_group_name         = var.resource_group_name
    location                    = var.location 
    azurefw_name                = var.azurefw_name
    azurefw_vnet_name           = azurerm_virtual_network.hub.name
    azurefw_addr_prefix         = var.azurefw_addr_prefix
}

# Azure Bastion
module "azure_bastion" { 
    source                      = "../azure_bastion"
    resource_group_name         = var.resource_group_name
    location                    = var.location
    azurebastion_name           = var.azurebastion_name
    azurebastion_vnet_name      = azurerm_virtual_network.hub.name
    azurebastion_addr_prefix    = var.azurebastion_addr_prefix
}