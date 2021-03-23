output "acr_id" { 
    description     = "Private ACR ID"
    value           = azurerm_container_registry.acr_instance.id
}