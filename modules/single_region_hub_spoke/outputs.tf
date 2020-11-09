output "hub_vnet_id" {
    description     = "Hub VNet Id"
    value           = azurerm_virtual_network.hub.id 
}

output "hub_vnet_name" { 
    description     = "Hub VNet Name"
    value           = azurerm_virtual_network.hub.name
}
