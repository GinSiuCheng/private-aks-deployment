# Azure Firewall TF Module
resource "azurerm_subnet" "azure_firewall" {
    name                        = "AzureFirewallSubnet"
    resource_group_name         = var.resource_group_name
    virtual_network_name        = var.azurefw_vnet_name
    address_prefixes            = [var.azurefw_addr_prefix]
} 

resource "azurerm_public_ip" "azure_firewall" {
    name                        = "azure_firewall_ip"
    location                    = var.location
    resource_group_name         = var.resource_group_name
    allocation_method           = "Static"
    sku                         = "Standard"
}

resource "azurerm_firewall" "azure_firewall_instance" { 
    name                        = var.azurefw_name
    location                    = var.location
    resource_group_name         = var.resource_group_name
    dns_servers                 = [ 
        var.bind_private_ip_addr 
    ]
    ip_configuration {
        name                    = "configuration"
        subnet_id               = azurerm_subnet.azure_firewall.id 
        public_ip_address_id    = azurerm_public_ip.azure_firewall.id
    }
}

resource "azurerm_firewall_network_rule_collection" "private_aks" {
    name                = "PrivateAKSNetworkRules"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = var.resource_group_name
    priority            = 100
    action              = "Allow"
    rule { 
        name = "NTP"
        source_addresses  = [ 
            "*" 
        ]
        destination_fqdns = [
            "ntp.ubuntu.com"
        ]
        destination_ports = [ 
            "123" 
        ]
        protocols = [ 
            "UDP" 
        ]
    }
    rule {
        name = "AzureMonitor"
        source_addresses = [ 
            "*" 
        ]
        destination_addresses = [ 
            "AzureMonitor" 
        ]
        destination_ports = [ 
            "443" 
        ]
        protocols = [ 
            "TCP" 
        ]
    }
}

resource "azurerm_firewall_application_rule_collection" "private_aks" { 
    name                = "PrivateAKSAppRules"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = var.resource_group_name
    priority            = 100
    action              = "Allow"
    rule {
        name = "AKSService_FQDNTag"
        source_addresses = [ 
            "*" 
        ]
        fqdn_tags = [ 
            "AzureKubernetesService" 
        ]
    }
    rule {
        name = "Ubuntu_application_rules"
        source_addresses = [ 
            "*" 
        ]
        target_fqdns = [ 
            "security.ubuntu.com",
            "changelogs.ubuntu.com",
            "azure.archive.ubuntu.com"
        ]
        protocol {
          port = "80"
          type = "Http"
        }
    }
}