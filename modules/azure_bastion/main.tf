# Azure Bastion TF Module
resource "azurerm_subnet" "azure_bastion" {
    name                        = "AzureBastionSubnet"
    resource_group_name         = var.resource_group_name
    virtual_network_name        = var.azurebastion_vnet_name
    address_prefixes            = [var.azurebastion_addr_prefix]
} 

resource "azurerm_public_ip" "azure_bastion" { 
    name                        = "azure_bastion_ip"
    location                    = var.location
    resource_group_name         = var.resource_group_name
    allocation_method           = "Static"
    sku                         = "Standard" 
}

# Bastion NSG Rules and association
resource "azurerm_network_security_group" "azure_bastion" {
  name                = "azure-bastion-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Bastion Inbound Rules
resource "azurerm_network_security_rule" "AllowHttpsInbound" {
  name                        = "AllowHttpsInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion.name
}
resource "azurerm_network_security_rule" "AllowGatewayManagerInbound" {
  name                        = "AllowGatewayManagerInbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion.name
}
resource "azurerm_network_security_rule" "AllowAzureLoadBalancerInbound" {
  name                        = "AllowAzureLoadBalancerInbound"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "443"
  destination_port_range      = "443"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion.name
}
resource "azurerm_network_security_rule" "AllowBastionHostCommunication" {
  name                        = "AllowBastionHostCommunication"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["5701","8080"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion.name
}

# Bastion Outbound Rules
resource "azurerm_network_security_rule" "AllowSshRdpOutbound" {
  name                        = "AllowSshRdpOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_ranges          = ["22","3389"]
  destination_port_ranges     = ["22","3389"]
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion.name
}
resource "azurerm_network_security_rule" "AllowAzureCloudOutbound" {
  name                        = "AllowAzureCloudOutbound"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "443"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion.name
}
resource "azurerm_network_security_rule" "AllowBastionCommunication" {
  name                        = "AllowBastionCommunication"
  priority                    = 120
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_ranges          = ["5701","8080"]
  destination_port_ranges     = ["5701","8080"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion.name
}
resource "azurerm_network_security_rule" "AllowGetSessionInformation" {
  name                        = "AllowGetSessionInformation"
  priority                    = 130
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "80"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion.name
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.azure_bastion.id
  network_security_group_id = azurerm_network_security_group.azure_bastion.id
  depends_on = [
    azurerm_network_security_rule.AllowHttpsInbound,
    azurerm_network_security_rule.AllowGatewayManagerInbound,
    azurerm_network_security_rule.AllowAzureLoadBalancerInbound,
    azurerm_network_security_rule.AllowBastionHostCommunication,
    azurerm_network_security_rule.AllowSshRdpOutbound,
    azurerm_network_security_rule.AllowAzureCloudOutbound,
    azurerm_network_security_rule.AllowBastionCommunication,
    azurerm_network_security_rule.AllowGetSessionInformation
  ]
}

# Azure Bastion Instance
resource "azurerm_bastion_host" "azure_bastion_instance" {
    name                        = var.azurebastion_name
    location                    = var.location
    resource_group_name         = var.resource_group_name

    ip_configuration { 
        name                    = "configuration"
        subnet_id               = azurerm_subnet.azure_bastion.id
        public_ip_address_id    = azurerm_public_ip.azure_bastion.id 
    }
}