resource "azurerm_role_definition" "private_aks_dns_write" {
  name        = "DNS Link Creation"
  scope       = data.azurerm_subscription.primary.id
  description = "Custom role for DNS Link Creation for private DNS zone"
  permissions {
    actions     = [
        "Microsoft.Network/privateDnsZones/read",
        "Microsoft.Network/privateDnsZones/write",
        "Microsoft.Network/privateDnsZones/A/read",
        "Microsoft.Network/privateDnsZones/A/write",
        "Microsoft.Network/privateDnsZones/virtualNetworkLinks/read"
    ]
    not_actions = [
        "Microsoft.Network/privateDnsZones/delete",
        "Microsoft.Network/privateDnsZones/A/delete",
        "Microsoft.Network/privateDnsZones/virtualNetworkLinks/delete",
    ]
  }
}