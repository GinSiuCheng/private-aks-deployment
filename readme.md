The following project demonstrates deployment of a private AKS cluster within a hub-spoke model with custom DNS. It consists of: 
1. Hub VNET with BIND DNS, Azure Bastion, Azure Firewall, Azure Private DNS and Azure Container Registry 
2. Spoke VNET with custom DNS to BIND DNS, Private AKS Cluster and UDR to Azure Firewall for Egress 