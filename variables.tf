variable "resource_group_name" {}
variable "location" {} 
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

# Hub-spoke module 
variable "hub_vnet_name" {}
variable "hub_vnet_addr_prefix" {}
variable "spoke_vnet_name" {}
variable "spoke_vnet_addr_prefix" {}
variable "azurefw_name" {}
variable "azurefw_addr_prefix" {}
variable "azurebastion_name" {}
variable "azurebastion_addr_prefix" {}

# Private ACR module 
variable "acr_addr_prefix" {}
variable "acr_name" {}
variable "acr_georeplication_locations" {}

# BIND DNS module 
variable "bind_dns_name" {}
variable "bind_dns_addr_prefix" {}
variable "bind_private_ip_addr" {}
variable "bind_ssh_source_addr_prefixes" {}
variable "vm_size" {}
variable "admin_username" {}
variable "pub_key_name" {}