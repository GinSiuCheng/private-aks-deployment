resource "azurerm_log_analytics_workspace" "this" {
    name                = var.law_name
    location            = var.location 
    resource_group_name = var.resource_group_name
    sku                 = var.law_sku
    retention_in_days   = var.law_retention_in_days
}