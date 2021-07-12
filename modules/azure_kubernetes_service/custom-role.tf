# resource "azurerm_role_definition" "private_aks_dns_write" {
#   name        = "DNS Link Creation"
#   scope       = data.azurerm_subscription.primary.id
#   description = "Custom role for DNS Link Creation for private DNS zone"
#   permissions {
#     actions     = [
#         "Microsoft.Network/privateDnsZones/read",
#         "Microsoft.Network/privateDnsZones/write",
#         "Microsoft.Network/privateDnsZones/A/read",
#         "Microsoft.Network/privateDnsZones/A/write",
#         "Microsoft.Network/privateDnsZones/virtualNetworkLinks/read"
#     ]
#     not_actions = [
#         "Microsoft.Network/privateDnsZones/delete",
#         "Microsoft.Network/privateDnsZones/A/delete",
#         "Microsoft.Network/privateDnsZones/virtualNetworkLinks/delete",
#     ]
#   }
# }


# # BYO Subnet and Route Table
# resource "azurerm_role_definition" "private_aks_route_table_perms" {
#   name        = "Kubenet Route Table Permissions"
#   scope       = data.azurerm_subscription.primary.id
#   permissions {
#     actions     = [
#         "Microsoft.Network/routeTables/read",
#         "Microsoft.Network/routeTables/write",
#         "Microsoft.Network/routeTables/routes/read",
#         "Microsoft.Network/routeTables/routes/write"
#     ]
#   }
# }
# resource "azurerm_role_assignment" "private_aks_route_table_perms" {
#     scope                = azurerm_route_table.private_aks.id
#     role_definition_id   = azurerm_role_definition.private_aks_route_table_perms.role_definition_resource_id
#     principal_id         = azurerm_user_assigned_identity.private_aks.principal_id
# }


# resource "azurerm_role_definition" "private_aks_vnet_perms" {
#   name        = "Kubenet VNET Permissions"
#   scope       = data.azurerm_subscription.primary.id
#   permissions {
#     actions     = [
#         "Microsoft.Network/virtualNetworks/subnets/join/action",
#         "Microsoft.Network/virtualNetworks/subnets/read",
#         "Microsoft.Network/virtualNetworks/read"
#     ]
#   }
# }
# resource "azurerm_role_assignment" "private_aks_vnet_perms" {
#     scope                = var.spoke_vnet_id
#     role_definition_id   = azurerm_role_definition.private_aks_vnet_perms.role_definition_resource_id
#     principal_id         = azurerm_user_assigned_identity.private_aks.principal_id
# }

# # Internal Load Balancer Creation rules 
# resource "azurerm_role_definition" "private_aks_slb_perms" {
#   name        = "Kubenet SLB Permissions"
#   scope       = data.azurerm_subscription.primary.id
#   permissions {
#     actions     = [
#         "Microsoft.Network/loadBalancers/*"
#     ]
#   }
# }
# resource "azurerm_role_assignment" "private_aks_slb_perms" {
#     scope                = data.azurerm_subscription.primary.id
#     role_definition_id   = azurerm_role_definition.private_aks_slb_perms.role_definition_resource_id
#     principal_id         = azurerm_user_assigned_identity.private_aks.principal_id
# }

# resource "azurerm_role_definition" "private_aks_nsg_perms" {
#   name        = "Kubenet NSG Permissions"
#   scope       = data.azurerm_subscription.primary.id
#   permissions {
#     actions     = [
#         "Microsoft.Network/networkSecurityGroups/write",
#         "Microsoft.Network/networkSecurityGroups/read"
#     ]
#   }
# }
# resource "azurerm_role_assignment" "private_aks_nsg_perms" {
#     scope                = azurerm_network_security_group.private_aks.id
#     role_definition_id   = azurerm_role_definition.private_aks_nsg_perms.role_definition_resource_id
#     principal_id         = azurerm_user_assigned_identity.private_aks.principal_id
# }