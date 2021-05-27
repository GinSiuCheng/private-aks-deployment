# Overview 
The following project demonstrates deployment of a private AKS cluster within a hub-spoke model with BYO Private DNS Zone. It consists of: 
1. Hub VNET with:
    1. Azure Bastion - Used SSH into BIND/Jump Box VMs/AKS Nodes
    2. Azure Firewall - Used for AKS Egress Filtering
    3. BIND DNS - Used as the DNS for Spoke VNET, Forwards to 168.63.129.16 for Private Endpoint resolution
    4. Private Endpoint Subnet for ACR/other shared resources
    5. Azure Private DNS for Private Endpoints [ACR, AKS]
2. Spoke VNET with:
    1. VNET Custom DNS Servers pointed to BIND DNS
    2. Private AKS Cluster with 
        1. Host-based Encryption Enabled: [Doc Ref.](https://docs.microsoft.com/en-us/azure/aks/enable-host-encryption)
        2. SSE with CMK: [Doc Ref.](https://docs.microsoft.com/en-us/azure/aks/azure-disk-customer-managed-keys)
        3. UDR to Azure FW for Egress: [Doc Ref.](https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic#restrict-egress-traffic-using-azure-firewall)

![Architecture Overview](hub-spoke-private-aks-udr.png)

# Module Design Principles:
As there are multiple ways to create TF modules and instantiate environment instances. I structured the repository in the following way: 
1. Single resources and their dependencies are grouped into a module 
2. Architecture templates are grouped into a module
3. There is only 2 degrees of nesting max: root main.tf --> module --> module

# Build and Environment Dependencies 
1. Terraform execution environment could be windows or linux based.
2. Leverage the azure cli login auth method within your dev environment.
3. Ensure you edit the bind_install.sh to reference your own blob storage location for config file storage and update named.conf.options allowedclients list. 
4. Generate PEM keys for VMs and AKS

# Generate SSH Keys for VM or AKS Access
To generate an ssh key pair for VM/AKS access, you can leverage the following command: 
ssh-keygen -m PEM -t rsa -b 4096 -f "key name"
Make sure to reference the right pem key location within your tfvars 

# Azure Bastion Host 
Azure Bastion host will be leveraged to SSH into VMs within the environment [ex. DNS Server, Jump Boxes and AKS nodes].