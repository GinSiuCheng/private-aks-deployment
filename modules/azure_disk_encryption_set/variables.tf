variable "resource_group_name" {}
variable "location" {}
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

variable "local_ips" {
    type        = tuple([string])
    description = "TF Deployment IPs"
}

variable "des_kv_name" {
    type        = string
    description = "DES Key Vault Name" 
}

variable "des_key_name" {
    type        = string
    description = "DES Key Name"
}

variable "des_name" {
    type        = string 
    description = "DES Name"
}

