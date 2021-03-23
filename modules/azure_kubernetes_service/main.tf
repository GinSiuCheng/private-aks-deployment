# Private AKS TF Module 
# Subnet for AKS 
resource "azurerm_subnet" "private_aks" {
    name                                            = "${var.aks_name}-subnet"
    resource_group_name                             = var.resource_group_name
    virtual_network_name                            = var.aks_vnet_name
    address_prefixes                                = [var.aks_subnet_addr_prefix]
    enforce_private_link_endpoint_network_policies  = true
} 

# Route table for AKS Subnet
resource "azurerm_route_table" "private_aks" { 
    name                    = "${var.aks_name}-route-table"
    resource_group_name     = var.resource_group_name
    location                = var.location
    disable_bgp_route_propagation = false

    route { 
        name                    = "Internet-Outbound"
        address_prefix          = "0.0.0.0/0"
        next_hop_type           = "VirtualAppliance"
        next_hop_in_ip_address  = var.azure_fw_private_ip
    }
}

resource "azurerm_subnet_route_table_association" "private_aks" {
    subnet_id       = azurerm_subnet.private_aks.id
    route_table_id  = azurerm_route_table.private_aks.id
}

# Private AKS Azure DNS 
resource "azurerm_private_dns_zone" "private_aks" {
    name                                            = "privatelink.${var.location}.azmk8s.io"
    resource_group_name                             = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_aks_zone_link" { 
    name                                            = "hub_private_aks_dns_vnet_link"
    resource_group_name                             = var.resource_group_name
    private_dns_zone_name                           = azurerm_private_dns_zone.private_aks.name 
    virtual_network_id                              = var.hub_vnet_id
    registration_enabled                            = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke_aks_dns_link" { 
    name                                            = "spoke_private_aks_dns_vnet_link"
    resource_group_name                             = var.resource_group_name
    private_dns_zone_name                           = azurerm_private_dns_zone.private_aks.name 
    virtual_network_id                              = var.spoke_vnet_id
    registration_enabled                            = false
}

# UserAssigned Identity
data "azurerm_subscription" "primary" {}

resource "azurerm_user_assigned_identity" "private_aks" {
    name                                            = "private-aks-identity"
    resource_group_name                             = var.resource_group_name
    location                                        = var.location
}

resource "azurerm_role_assignment" "private_aks_role" {
    scope                                           = azurerm_private_dns_zone.private_aks.id
    role_definition_name                            = "Private DNS Zone Contributor"
    principal_id                                    = azurerm_user_assigned_identity.private_aks.principal_id
    depends_on = [
        azurerm_private_dns_zone.private_aks
    ]
}

# Private AKS Instantiation
resource "azurerm_kubernetes_cluster" "private_aks" { 
    name                            = var.aks_name
    location                        = var.location 
    resource_group_name             = var.resource_group_name
    dns_prefix                      = var.aks_dns_prefix
    kubernetes_version              = var.aks_k8s_version
    private_cluster_enabled         = true 
    private_dns_zone_id             = azurerm_private_dns_zone.private_aks.id
    node_resource_group             = "${var.aks_name}-node-rg"

    identity { 
        type                                = "UserAssigned"
        user_assigned_identity_id           = azurerm_user_assigned_identity.private_aks.id
    }

    linux_profile { 
        admin_username              = var.aks_admin_username
        ssh_key { 
            key_data                = file(var.aks_pub_key_name)
        }
    }

    default_node_pool { 
        name                        = var.aks_default_pool_name
        node_count                  = var.aks_default_pool_node_count
        vm_size                     = var.aks_default_pool_vm_size
        os_disk_size_gb             = var.aks_default_pool_os_disk_size
        vnet_subnet_id              = azurerm_subnet.private_aks.id
    }

    network_profile { 
        network_plugin                  = "azure"
        service_cidr                    = var.aks_service_cidr
        dns_service_ip                  = var.aks_dns_service_ip
        docker_bridge_cidr              = var.aks_docker_bridge_cidr
        load_balancer_sku               = "standard"
        outbound_type                   = "userDefinedRouting"
    }
    
    depends_on = [ 
        azurerm_subnet.private_aks,
        azurerm_route_table.private_aks, 
        azurerm_subnet_route_table_association.private_aks,
        azurerm_private_dns_zone.private_aks,
        azurerm_private_dns_zone_virtual_network_link.hub_aks_zone_link,
        azurerm_private_dns_zone_virtual_network_link.spoke_aks_dns_link,
        azurerm_role_assignment.private_aks_role
    ]
}

data "azurerm_user_assigned_identity" "private_aks" {
    name                            = "${azurerm_kubernetes_cluster.private_aks.name}-agentpool"
    resource_group_name             = "${var.aks_name}-node-rg"
    depends_on = [ 
        azurerm_kubernetes_cluster.private_aks
    ]
}