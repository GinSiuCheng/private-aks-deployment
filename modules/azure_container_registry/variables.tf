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

variable "acr_georeplication_locations" { 
    type        = tuple([string])
    description = "Georeplication locations for ACR, must be different from primary ACR location"
}