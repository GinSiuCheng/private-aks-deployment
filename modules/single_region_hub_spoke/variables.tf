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
variable "azurefw_name" {}
variable "azurefw_addr_prefix" {}

# Azure Bastion Variables 
variable "azurebastion_name" {}
variable "azurebastion_addr_prefix" {}

# BIND DNS module 
variable "bind_dns_name" {}
variable "bind_dns_addr_prefix" {}
variable "bind_private_ip_addr" {}
variable "bind_ssh_source_addr_prefixes" {}
variable "bind_vm_size" {}
variable "bind_admin_username" {}
variable "bind_pub_key_name" {}

# Jump host module
variable "jump_host_name" {}
variable "jump_host_addr_prefix" {}
variable "jump_host_private_ip_addr" {}
variable "jump_host_ssh_source_addr_prefixes" {}
variable "jump_host_vm_size" {}
variable "jump_host_admin_username" {}
variable "jump_host_pub_key_name" {}