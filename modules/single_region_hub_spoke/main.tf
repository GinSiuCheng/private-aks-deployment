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
    dns_servers                 = [var.bind_private_ip_addr]
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
    bind_private_ip_addr        = var.bind_private_ip_addr
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

# BIND DNS
module "bind_dns" { 
    source                          = "../bind_dns"
    resource_group_name             = var.resource_group_name
    location                        = var.location
    bind_dns_name                   = var.bind_dns_name
    bind_vnet_name                  = azurerm_virtual_network.hub.name
    bind_dns_addr_prefix            = var.bind_dns_addr_prefix
    bind_private_ip_addr            = var.bind_private_ip_addr
    bind_ssh_source_addr_prefixes   = var.bind_ssh_source_addr_prefixes
    bind_vm_size                    = var.bind_vm_size
    bind_admin_username             = var.bind_admin_username
    bind_pub_key_name               = var.bind_pub_key_name
}

# Jump Host
module "jump_host" { 
    source                               = "../jump_host"
    resource_group_name                  = var.resource_group_name
    location                             = var.location
    jump_host_name                       = var.jump_host_name
    jump_host_vnet_name                  = azurerm_virtual_network.hub.name
    jump_host_addr_prefix                = var.jump_host_addr_prefix
    jump_host_private_ip_addr            = var.jump_host_private_ip_addr
    jump_host_ssh_source_addr_prefixes   = var.jump_host_ssh_source_addr_prefixes
    jump_host_vm_size                    = var.jump_host_vm_size
    jump_host_admin_username             = var.jump_host_admin_username
    jump_host_pub_key_name               = var.jump_host_pub_key_name
}