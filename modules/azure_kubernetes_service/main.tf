# Private AKS TF Module 
# Subnet for AKS 
resource "azurerm_subnet" "private_aks" {
    name                                            = "${var.aks_name}-subnet"
    resource_group_name                             = var.resource_group_name
    virtual_network_name                            = var.aks_vnet_name
    address_prefixes                                = [var.aks_subnet_addr_prefix]
    enforce_private_link_service_network_policies   = false
} 

resource "null_resource" "dns_zone_link" {
  provisioner "local-exec" {
    interpreter = ["bash"]
    command = "modules/azure_kubernetes_service/dns-zone-link.sh"

    environment = {
      DNS_VNET                      = var.custom_dns_vnet_id 
      AKS_RESOURCE_GROUP            = var.resource_group_name
      AKS_CLUSTER_NAME              = var.aks_name
    }
  }
}

resource "azurerm_kubernetes_cluster" "private_aks" { 
    name                            = var.aks_name
    location                        = var.location 
    resource_group_name             = var.resource_group_name
    dns_prefix                      = var.aks_dns_prefix
    kubernetes_version              = var.aks_k8s_version
    private_cluster_enabled         = true 

    identity { 
        type = "SystemAssigned"
    }

    linux_profile { 
        admin_username              = var.aks_admin_username
        ssh_key { 
            key_data                = "${file("${var.aks_pub_key_name}")}"
        }
    }

    default_node_pool { 
        name                        = var.aks_default_pool_name
        node_count                  = var.aks_default_pool_node_count
        vm_size                     = var.aks_default_pool_vm_size
        os_disk_size_gb             = var.aks_default_pool_os_disk_size
        vnet_subnet_id              = azurerm_subnet.private_aks.id
    }

    network_profile { 
        network_plugin              = "azure"
        service_cidr                = var.aks_service_cidr
        dns_service_ip              = var.aks_dns_service_ip
        docker_bridge_cidr          = var.aks_docker_bridge_cidr
        load_balancer_sku           = "standard"
    }
}
