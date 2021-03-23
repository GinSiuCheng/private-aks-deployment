output "private_aks_msi_id" { 
    description     = "Private AKS Node MSI ID"
    value           = data.azurerm_user_assigned_identity.private_aks.principal_id
}
