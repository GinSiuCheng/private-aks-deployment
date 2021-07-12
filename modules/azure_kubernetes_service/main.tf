# Private AKS TF Module 
data "azurerm_resource_group" "private_aks_demo" {
    name = var.resource_group_name
}

# Subnet for AKS 
resource "azurerm_subnet" "private_aks" {
    name                                            = "${var.aks_name}-subnet"
    resource_group_name                             = var.resource_group_name
    virtual_network_name                            = var.aks_vnet_name
    address_prefixes                                = [var.aks_subnet_addr_prefix]
    enforce_private_link_endpoint_network_policies  = true
} 

resource "azurerm_network_security_group" "private_aks" {
  name                = "private-aks-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "private_aks" {
  subnet_id                 = azurerm_subnet.private_aks.id
  network_security_group_id = azurerm_network_security_group.private_aks.id
}

# Route table for AKS Subnet
resource "azurerm_route_table" "private_aks" { 
    name                          = "${var.aks_name}-route-table"
    resource_group_name           = var.resource_group_name
    location                      = var.location
    disable_bgp_route_propagation = false
    tags                          = var.tags 
}

resource "azurerm_route" "internet_egress" {
    name                    = "Internet-Outbound"
    resource_group_name     = var.resource_group_name
    route_table_name        = azurerm_route_table.private_aks.name 
    address_prefix          = "0.0.0.0/0"
    next_hop_type           = "VirtualAppliance"
    next_hop_in_ip_address  = var.azure_fw_private_ip
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

# UserAssigned Identity and Permissions
data "azurerm_subscription" "primary" {}

resource "azurerm_user_assigned_identity" "private_aks" {
    name                                            = "private-aks-identity"
    resource_group_name                             = var.resource_group_name
    location                                        = var.location
}

# BYO Private DNS Zone permissions
resource "azurerm_role_assignment" "private_aks_dns_contributor" {
    scope                = azurerm_private_dns_zone.private_aks.id
    role_definition_name = "Private DNS Zone Contributor"
    principal_id         = azurerm_user_assigned_identity.private_aks.principal_id
}

# BYO Subnet, Route Table, SLB and NSG permissions
resource "azurerm_role_assignment" "private_aks_network_contributor" {
    scope                = data.azurerm_resource_group.private_aks_demo.id
    role_definition_name = "Network Contributor"
    principal_id         = azurerm_user_assigned_identity.private_aks.principal_id
}

# Host-based encryption and BYOK for Disk Encryption
resource "azurerm_role_assignment" "private_aks_des_reader" {
    scope                = var.disk_encryption_set_id
    role_definition_name = "Reader"
    principal_id         = azurerm_user_assigned_identity.private_aks.principal_id
}

# Wait 5min for role assignment to propagate 
resource "time_sleep" "wait_5min" {
    depends_on = [
      azurerm_role_assignment.private_aks_dns_contributor,
      azurerm_role_assignment.private_aks_des_reader,
      azurerm_role_assignment.private_aks_network_contributor
    ]
    create_duration = "300s"
}

# Private AKS Instantiation
resource "azurerm_kubernetes_cluster" "private_aks" { 
    name                            = var.aks_name
    location                        = var.location 
    resource_group_name             = var.resource_group_name
    dns_prefix                      = var.aks_dns_prefix    # Produces an a record of <dns-prefix>-<random guid>
    # dns_prefix_private_cluster      = var.aks_dns_prefix  # Produces an a record of <dns-prefix-private-cluster> (no random guid)
    kubernetes_version              = var.aks_k8s_version
    private_cluster_enabled         = true 
    private_dns_zone_id             = azurerm_private_dns_zone.private_aks.id
    node_resource_group             = "${var.aks_name}-node-rg"
    disk_encryption_set_id          = var.disk_encryption_set_id
    tags                            = var.tags

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

    # AAD Auth Integration 
    dynamic "role_based_access_control" {
        for_each = var.aks_aad_rbac.enabled ? [1] : []
        content {
            enabled = var.aks_aad_rbac.enabled
            azure_active_directory {
                managed = true 
                admin_group_object_ids = var.aks_aad_rbac.admin_group_object_ids
            }
        }
    }

    # Container Insights 
    addon_profile {
        dynamic "oms_agent" {
            for_each = var.aks_monitoring.enabled ? [1] : []
            content {
                enabled                    = var.aks_monitoring.enabled 
                log_analytics_workspace_id = var.aks_monitoring.log_analytics_workspace_id
            }
        }
    }

    default_node_pool { 
        name                        = var.aks_default_pool_name
        node_count                  = var.aks_default_pool_node_count
        vm_size                     = var.aks_default_pool_vm_size
        os_disk_size_gb             = var.aks_default_pool_os_disk_size
        availability_zones          = var.availability_zones
        vnet_subnet_id              = azurerm_subnet.private_aks.id
        enable_host_encryption      = true 
        tags                        = var.tags 
    }

    network_profile { 
        network_plugin                  = var.aks_network_plugin
        service_cidr                    = var.aks_service_cidr
        dns_service_ip                  = var.aks_dns_service_ip
        docker_bridge_cidr              = var.aks_docker_bridge_cidr
        load_balancer_sku               = "standard"
        outbound_type                   = "userDefinedRouting"
    }
    
    depends_on = [ 
        azurerm_subnet.private_aks,
        azurerm_route_table.private_aks, 
        azurerm_route.internet_egress,
        azurerm_subnet_route_table_association.private_aks,
        azurerm_private_dns_zone.private_aks,
        azurerm_private_dns_zone_virtual_network_link.hub_aks_zone_link,
        azurerm_private_dns_zone_virtual_network_link.spoke_aks_dns_link,
        time_sleep.wait_5min
    ]
}

resource "azurerm_kubernetes_cluster_node_pool" "application" {
    name                    = "appnodepool"
    kubernetes_cluster_id   = azurerm_kubernetes_cluster.private_aks.id 
    vm_size                 = "Standard_DS2_v2"
    node_count              = 3
    vnet_subnet_id          = azurerm_subnet.private_aks.id
    enable_host_encryption  = true 
    availability_zones      = var.availability_zones
    tags                    = var.tags
}