variable "resource_group_name" {}
variable "location" {}
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

variable "acr_vnet_name" {
    type        = string
    description = "VNet where the ACR will be deployed to"
}

variable "acr_vnet_id" { 
    type        = string 
    description = "VNET ID where the ACR will be deployed to"
}

variable "acr_subnet_name" {
    type        = string
    description = "ACR Subnet Name"
    default     = "acr_subnet"
}

variable "acr_addr_prefix" {
    type        = string
    description = "Address prefix for ACR Private Endpoint Subnet. Ex. 10.0.0.0/24"
}

variable "acr_name" {
    type        = string
    description = "Name of the ACR"
}

variable "acr_kv_name" {
    type        = string
    description = "Name of ACR KV"
}

variable "acr_key_name" {
    type        = string
    description = "Name of ACR KV Key"
}

variable "local_ips" {
    type        = tuple([string])
    description = "TF Deployment IPs"
}