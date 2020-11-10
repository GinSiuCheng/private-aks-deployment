# Azure provider version 
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
    version = "=2.32.0"
    features {} 
}

# Resource group 
resource "azurerm_resource_group" "private_aks_demo" {
    name                        = var.resource_group_name
    location                    = var.location
    tags                        = var.tags 
}

# Hub-Spoke VNET, Azure Bastion, Azure Firewall, BIND DNS 
module "hub_spoke" { 
    source                          = "./modules/single_region_hub_spoke"
    resource_group_name             = var.resource_group_name
    location                        = var.location

    hub_vnet_name                   = var.hub_vnet_name
    hub_vnet_addr_prefix            = var.hub_vnet_addr_prefix
    spoke_vnet_name                 = var.spoke_vnet_name
    spoke_vnet_addr_prefix          = var.spoke_vnet_addr_prefix

    azurefw_name                    = var.azurefw_name
    azurefw_addr_prefix             = var.azurefw_addr_prefix

    azurebastion_name               = var.azurebastion_name
    azurebastion_addr_prefix        = var.azurebastion_addr_prefix

    bind_dns_name                   = var.bind_dns_name
    bind_dns_addr_prefix            = var.bind_dns_addr_prefix
    bind_private_ip_addr            = var.bind_private_ip_addr
    bind_ssh_source_addr_prefixes   = var.bind_ssh_source_addr_prefixes
    vm_size                         = var.vm_size
    admin_username                  = var.admin_username
    pub_key_name                    = var.pub_key_name
}

# Azure Container Registry, Azure Private DNS and Hub Private Endpoint Subnet
module "private_acr" { 
    source                          = "./modules/azure_container_registry"
    resource_group_name             = var.resource_group_name
    location                        = var.location
    acr_vnet_name                   = module.hub_spoke.hub_vnet_name
    acr_vnet_id                     = module.hub_spoke.hub_vnet_id
    acr_addr_prefix                 = var.acr_addr_prefix
    acr_name                        = var.acr_name
    acr_georeplication_locations    = var.acr_georeplication_locations
}
