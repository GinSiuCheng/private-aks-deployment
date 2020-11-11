variable "resource_group_name" {}
variable "location" {}
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

variable "bind_dns_name" {
    type        = string 
    description = "BIND DNS Name"
}

variable "bind_vnet_name" { 
    type        = string 
    description = "VNET where BIND DNS will be deployed"
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

variable "bind_vm_size" { 
    type        = string
    description = "Specify size of BIND DNS Instance. Defaults to Standard_DS3_v2"
    default     = "Standard_DS3_v2"
}

variable "bind_admin_username" { 
    type        = string 
    description = "BIND VM Username"
}

variable "bind_pub_key_name" { 
    type        = string 
    description = "Local public key name"
}