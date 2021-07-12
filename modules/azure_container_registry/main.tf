# Azure Container Registry TF Module 
data "azurerm_client_config" "current" {}

# ACR Subnet for Private Endpoint 
resource "azurerm_subnet" "acr" {
    name                                            = var.acr_subnet_name
    resource_group_name                             = var.resource_group_name
    virtual_network_name                            = var.acr_vnet_name
    address_prefixes                                = [var.acr_addr_prefix]
    enforce_private_link_endpoint_network_policies  = true 
} 

# ACR Azure DNS 
resource "azurerm_private_dns_zone" "acr" {
    name                                            = "privatelink.azurecr.io"
    resource_group_name                             = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" { 
    name                                            = "acr_private_dns_vnet_link"
    resource_group_name                             = var.resource_group_name
    private_dns_zone_name                           = azurerm_private_dns_zone.acr.name 
    virtual_network_id                              = var.acr_vnet_id 
    registration_enabled                            = false 
}

# User assigned identity for ACR
resource "azurerm_user_assigned_identity" "acr" {
    name                                            = "acr-cmk-identity"
    resource_group_name                             = var.resource_group_name
    location                                        = var.location
}

# Key Vault Instance for ACR Encryption
resource "azurerm_key_vault" "acr" {
    name                        = var.acr_kv_name
    location                    = var.location 
    resource_group_name         = var.resource_group_name
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    sku_name                    = "standard"
    enabled_for_disk_encryption = true
    purge_protection_enabled    = true
}

# Current user access policy
resource "azurerm_key_vault_access_policy" "current_user" {
    key_vault_id = azurerm_key_vault.acr.id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = data.azurerm_client_config.current.object_id

    key_permissions = [ 
        "Get",
        "Create",
        "Delete",
        "Decrypt",
        "Backup",
        "List",
        "Purge",
        "Recover",
        "Restore",
        "Update"
    ]
}

# User and system identity assignment 
resource "azurerm_key_vault_access_policy" "acr_uai" { 
    key_vault_id = azurerm_key_vault.acr.id
    tenant_id    = azurerm_user_assigned_identity.acr.tenant_id
    object_id    = azurerm_user_assigned_identity.acr.principal_id
    
    key_permissions = [
        "get",
        "wrapKey",
        "unwrapKey"
    ]
}

# Wait 2min for policy to propagate 
resource "time_sleep" "wait_2min" {
    depends_on = [
        azurerm_key_vault_access_policy.acr_uai,
        azurerm_key_vault_access_policy.current_user
    ]
    create_duration = "120s"
}

# Encryption Key 
resource "azurerm_key_vault_key" "acr_key" {
    name         = var.acr_key_name
    key_size     = 2048
    key_type     = "RSA"
    key_vault_id = azurerm_key_vault.acr.id
    key_opts = [
        "decrypt",
        "encrypt",
        "sign",
        "unwrapKey",
        "verify",
        "wrapKey"
    ]

    depends_on = [
        azurerm_key_vault_access_policy.current_user,
        azurerm_key_vault_access_policy.acr_uai,
        time_sleep.wait_2min
    ]
}

# ACR 
resource "azurerm_container_registry" "acr_instance" { 
    name                                            = var.acr_name 
    resource_group_name                             = var.resource_group_name
    location                                        = var.location
    sku                                             = "Premium"
    
    identity {
        type         = "SystemAssigned, UserAssigned"
        identity_ids = [
            azurerm_user_assigned_identity.acr.id
        ] 
    }

    encryption {
        enabled             = true 
        key_vault_key_id    = azurerm_key_vault_key.acr_key.id
        identity_client_id  = azurerm_user_assigned_identity.acr.client_id
    }

    network_rule_set { 
        default_action = "Deny"
    }
    
    depends_on = [
      time_sleep.wait_2min,
      azurerm_key_vault_key.acr_key
    ]
}

# Only system assigned identity works with "trusted azure services" network settings
# https://docs.microsoft.com/en-us/azure/container-registry/container-registry-customer-managed-keys#advanced-scenario-key-vault-firewall
# This script creates an ACR system assigned identity access policy to key vault and re-enables the key vault fw post deployment

resource "null_resource" "system_identity_and_fw_enablement" {
    provisioner "local-exec" {
        command = <<EOS
        principalId=$(az acr identity show --name ${azurerm_container_registry.acr_instance.name} --query principalId --output tsv | tr -d "\r")
        tenantId=$(az acr identity show --name ${azurerm_container_registry.acr_instance.name} --query tenantId --output tsv | tr -d "\r")
        az keyvault set-policy -n ${azurerm_key_vault.acr.name} --key-permissions get unwrapKey wrapKey --object-id $principalId
        sleep 2m
        az acr encryption rotate-key -g ${var.resource_group_name} -n ${azurerm_container_registry.acr_instance.name} --identity '[system]' --key-encryption-key ${azurerm_key_vault_key.acr_key.id}
        az keyvault update -g ${var.resource_group_name} -n ${azurerm_key_vault.acr.name} --bypass "AzureServices";
        az keyvault update -g ${var.resource_group_name} -n ${azurerm_key_vault.acr.name} --default-action "Deny";
        az keyvault network-rule add -g ${var.resource_group_name} -n ${azurerm_key_vault.acr.name} --ip-address ${var.local_ips[0]}
        EOS
    }
    depends_on = [
        time_sleep.wait_2min,
        azurerm_key_vault.acr,
        azurerm_container_registry.acr_instance
    ]
}

# ACR Private Endpoint 
resource "azurerm_private_endpoint" "acr" {
    name                                            = "${var.acr_name}_private_endpoint"
    location                                        = var.location
    resource_group_name                             = var.resource_group_name
    subnet_id                                       = azurerm_subnet.acr.id

    private_dns_zone_group { 
        name                                        = "${var.acr_name}_dns_zone_group"
        private_dns_zone_ids                        = [azurerm_private_dns_zone.acr.id]
    }

    private_service_connection { 
        name                                        = "${var.acr_name}_connection"
        private_connection_resource_id              = azurerm_container_registry.acr_instance.id
        subresource_names                           = ["registry"]
        is_manual_connection                        = false
    }
    depends_on = [
        azurerm_subnet.acr,
        null_resource.system_identity_and_fw_enablement
    ]
}


