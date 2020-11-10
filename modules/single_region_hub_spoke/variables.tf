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

# BIND DNS module 
variable "bind_dns_name" {
    type        = string 
    description = "BIND DNS Name"
}

variable "bind_dns_addr_prefix" { 
    type        = string 
    description = "BIND DNS Subnet Address Prefix"
}

variable "bind_private_ip_addr" {
    type        = string 
    description = "Private IP Address for BIND"
}

variable "bind_ssh_source_addr_prefixes" { 
    type        = tuple([string])
    description = "BIND SSH Source Addr Prefixes for NSG Rule"
}

variable "vm_size" { 
    type        = string
    description = "Specify size of BIND DNS Instance. Defaults to Standard_DS3_v2"
    default     = "Standard_DS3_v2"
}

variable "admin_username" { 
    type        = string 
    description = "BIND VM Username"
}

variable "pub_key_name" { 
    type        = string 
    description = "Local public key name"
}