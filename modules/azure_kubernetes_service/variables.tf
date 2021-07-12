variable "resource_group_name" {}
variable "location" {}
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

variable "aks_name" {
    type        = string
    description = "Name of the AKS cluster"
}

variable "aks_vnet_name" {
    type        = string
    description = "VNET where AKS will be deployed to"
}

variable "aks_subnet_addr_prefix" {
    type        = string
    description = "AKS Subnet Address Prefix"
}

variable "hub_vnet_id" {
    type        = string
    description = "VNET ID where the DNS resides"
}

variable "spoke_vnet_id" {
    type        = string
    description = "VNET ID where the DNS resides"
}

variable "aks_dns_prefix" {
    type        = string
    description = "AKS DNS Prefix"
}

variable "aks_k8s_version" {
    type        = string
    description = "AKS k8s version"
}

variable "aks_admin_username" {
    type        = string
    description = "AKS admin username"
    default     = "azureuser"
}

variable "aks_pub_key_name" {
    type        = string
    description = "File path to your public key"
}

variable "aks_default_pool_name" {
    type        = string
    description = "Name of the default node pool"
    default     = "system"
}

variable "aks_default_pool_node_count" {
    type        = number
    description = "Number of ndoes in default pool, defaults to 3 nodes over 3AZs"
    default     = 3 
}

variable "aks_default_pool_vm_size" {
    type        = string
    description = "Default VM node sizes, default setting is Standard_D4s_v4 in this module."
    default     = "Standard_D4s_v4"
}

variable "aks_default_pool_os_disk_size" {
    type        = number
    description = "OS Disk size for default pool"
    default     = 1024
}

variable "aks_service_cidr" {
    type        = string
    description = "AKS service CIDR, default setting is 10.0.0.0/16 in this module"
    default     = "10.0.0.0/16"
}

variable "aks_dns_service_ip" {
    type        = string
    description = "AKS DNS service ip, default setting is 10.0.0.10 in this module"
    default     = "10.0.0.10"
}

variable "aks_docker_bridge_cidr" {
    type        = string
    description = "AKS Docker Bridge CIDR, default setting is 172.17.0.1/16 in this module."
    default     = "172.17.0.1/16"
}

variable "azure_fw_private_ip" { 
    type        = string 
    description = "Azure FW Private IP"
}

variable "availability_zones" { 
    description = "AZs for nodes"
    default     = ["1","2","3"]
}

variable "disk_encryption_set_id" {
    type        = string
    description = "Disk Encryption Set ID"
}

variable "aks_network_plugin" {
    type        = string
    description = "AKS Network Plugin Setting, defaults to Azure CNI"
    default     = "azure"
}

variable "aks_aad_rbac" {
    type        = object({
        enabled                = bool 
        admin_group_object_ids = tuple([string])
    })
    default     = {
        enabled                = false 
        admin_group_object_ids = null 
    }
}

variable "aks_monitoring" {
    type        = object({
        enabled                    = bool 
        log_analytics_workspace_id = string 
    })
    default     = {
        enabled                     = false 
        log_analytics_workspace_id  = null 
    }
}