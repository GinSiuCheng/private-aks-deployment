variable "resource_group_name" {}
variable "location" {}
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

variable "jump_host_name" {
    type        = string 
    description = "Jump Host Name"
}

variable "jump_host_vnet_name" { 
    type        = string 
    description = "VNET where Jump Host will be deployed"
}

variable "jump_host_addr_prefix" { 
    type        = string 
    description = "Jump Host Subnet Address Prefix"
}

variable "jump_host_private_ip_addr" {
    type        = string 
    description = "Private IP Address for Jump Host"
}

variable "jump_host_ssh_source_addr_prefixes" { 
    type        = tuple([string])
    description = "Jump Host SSH Source Addr Prefixes for NSG Rule"
}

variable "jump_host_vm_size" { 
    type        = string
    description = "Specify size of Jump Host Instance. Defaults to Standard_DS3_v2"
    default     = "Standard_DS3_v2"
}

variable "jump_host_admin_username" { 
    type        = string 
    description = "jump_host VM Username"
}

variable "jump_host_pub_key_name" { 
    type        = string 
    description = "Local public key name"
}