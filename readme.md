The following project demonstrates deployment of a private AKS cluster within a hub-spoke model with custom DNS. It consists of: 
1. Hub VNET with:
    1. Azure Bastion 
    2. Azure Firewall 
    3. BIND DNS 
    4. Private Endpoint Subnet for ACR/other shared resources
    5. Azure Private DNS for Private Endpoints
2. Spoke VNET with:
    1. Custom DNS pointed BIND DNS
    2. Private AKS Cluster with UDR to Azure Firewall for Egress
 