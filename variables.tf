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