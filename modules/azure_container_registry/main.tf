# Azure Container Registry TF Module 
# ACR Subnet for Private Endpoint 
resource "azurerm_subnet" "acr" {
    name                                            = var.acr_subnet_name
    resource_group_name                             = var.resource_group_name
    virtual_network_name                            = var.acr_vnet_name
    address_prefixes                                = [var.acr_addr_prefix]
    enforce_private_link_endpoint_network_policies  = true 
} 

# ACR Azure DNS 
resource "azurerm_private_dns_zone" "acr" {
    name                                            = "privatelink.azurecr.io"
    resource_group_name                             = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" { 
    name                                            = "acr_private_dns_vnet_link"
    resource_group_name                             = var.resource_group_name
    private_dns_zone_name                           = azurerm_private_dns_zone.acr.name 
    virtual_network_id                              = var.acr_vnet_id 
    registration_enabled                            = false 
}

# ACR 
resource "azurerm_container_registry" "acr_instance" { 
    name                                            = var.acr_name 
    resource_group_name                             = var.resource_group_name
    location                                        = var.location
    sku                                             = "Premium"
    network_rule_set { 
        default_action = "Deny"
    }
    georeplication_locations                        = var.acr_georeplication_locations
}

# ACR Private Endpoint 
resource "azurerm_private_endpoint" "acr" {
    name                                            = "${var.acr_name}_private_endpoint"
    location                                        = var.location
    resource_group_name                             = var.resource_group_name
    subnet_id                                       = azurerm_subnet.acr.id

    private_dns_zone_group { 
        name                                        = "${var.acr_name}_dns_zone_group"
        private_dns_zone_ids                        = [azurerm_private_dns_zone.acr.id]
    }

    private_service_connection { 
        name                                        = "${var.acr_name}_connection"
        private_connection_resource_id              = azurerm_container_registry.acr_instance.id
        subresource_names                           = ["registry"]
        is_manual_connection                        = false
    }
    depends_on = [
        azurerm_subnet.acr
    ]
}
