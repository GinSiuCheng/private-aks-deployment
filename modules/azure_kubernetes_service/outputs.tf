# Kubelet MSI ID is needed for AcrPull Assignment: https://docs.microsoft.com/en-us/azure/aks/cluster-container-registry-integration#configure-acr-integration-for-existing-aks-clusters
# When BYO MSI for Kubelet is GA, deriving the Kubelet MSI would no longer be needed and ACR access can be pre-assigned to user provisioned kubelet MSI.
output "private_aks_kubelet_msi_id" { 
    description     = "Private AKS Kubelet MSI ID"
    value           = azurerm_kubernetes_cluster.private_aks.kubelet_identity.0.object_id
}
