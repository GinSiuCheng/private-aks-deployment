# Overview 
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
 
# Module Design Principles:
As there are multiple ways to create TF modules and instantiate environment instances. We structured the repository in the following way: 
1. Single resources and their dependencies are grouped into a module 
2. Architecture templates are grouped into a module
3. There is only 2 degrees of nesting max: root (main.tf) --> module --> module

# Generate SSH Keys for VM or AKS Access
To generate an ssh key pair for VM access, you can leverage the following command: 
ssh-keygen -m PEM -t rsa -b 4096 -f "key name"

# Build/Terraform Environment Dependencies
You will need the jq lib in a linux/windows context. Install on linux with sudo apt-get install jq