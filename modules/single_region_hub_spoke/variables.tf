variable "resource_group_name" {}
variable "location" {} 

variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

# Hub-Spoke Variables
variable "hub_vnet_name" {
    type        = string 
    description = "VNet name for hub-vnet"
    default     = "hub-vnet"
}

variable "hub_vnet_addr_prefix" { 
    type        = string
    description = "VNet address prefix"
    default     = "10.0.0.0/16"
}

variable "spoke_vnet_name" {
    type        = string 
    description = "VNet name for spoke-vnet"
    default     = "spoke-vnet"
}

variable "spoke_vnet_addr_prefix" { 
    type        = string
    description = "VNet address prefix"
    default     = "10.1.0.0/16"
}

# Azure Firewall Variables
variable "azurefw_name" {
    type        = string
    description = "AzureFW Name"
}

variable "azurefw_addr_prefix" {
    type        = string
    description = "Address prefix for AzureFW Subnet. Ex. 10.0.0.0/24"
}

# Azure Bastion Variables 
variable "azurebastion_name" {
    type        = string
    description = "azurebastion Name"
}

variable "azurebastion_addr_prefix" {
    type        = string
    description = "Address prefix for Azure Bastion Subnet. Ex. 10.0.0.0/24"
}