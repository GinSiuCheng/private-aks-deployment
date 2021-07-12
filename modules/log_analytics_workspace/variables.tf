variable "resource_group_name" {}
variable "location" {}
variable "tags" {
    type        = map 
    default     = { 
        Environment = "development"
    }
}

variable "law_name" {
    type        = string
    description = "Name of Log Analytics Workspace"
}

variable "law_sku" {
    type        = string 
    description = "LA Workspace SKU"
    default     = "PerGB2018"
}

variable "law_retention_in_days" {
    type        = number 
    description = "Retention period for LA Workspace"
    default     = 30
}