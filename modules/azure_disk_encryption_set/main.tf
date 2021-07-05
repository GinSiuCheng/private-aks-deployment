# Azure DES TF Module
data "azurerm_client_config" "current" {}

# Key Vault Instance for DES
resource "azurerm_key_vault" "des_kv" {
    name                        = var.des_kv_name 
    location                    = var.location 
    resource_group_name         = var.resource_group_name
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    sku_name                    = "standard"
    enabled_for_disk_encryption = true
    purge_protection_enabled    = true

    # Allow Azure Trusted Services 
    network_acls {
        bypass         = "AzureServices"
        default_action = "Deny"
        ip_rules       = var.local_ips
    }
}

# Current user access policy
resource "azurerm_key_vault_access_policy" "current_user" {
    key_vault_id = azurerm_key_vault.des_kv.id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = data.azurerm_client_config.current.object_id

    key_permissions = [ 
        "Get",
        "Create",
        "Delete",
        "Purge",
        "Recover"
    ]
}

# Encryption Key 
resource "azurerm_key_vault_key" "des_key" {
    name         = var.des_key_name
    key_size     = 2048
    key_type     = "RSA"
    key_vault_id = azurerm_key_vault.des_kv.id
    key_opts = [
        "decrypt",
        "encrypt",
        "sign",
        "unwrapKey",
        "verify",
        "wrapKey"
    ]
    depends_on = [ 
        azurerm_key_vault_access_policy.current_user
    ]
}

# DES 
resource "azurerm_disk_encryption_set" "des" {
    name                = var.des_name
    resource_group_name = var.resource_group_name
    location            = var.location 
    key_vault_key_id    = azurerm_key_vault_key.des_key.id

    identity {
        type = "SystemAssigned"
    }
}

resource "azurerm_key_vault_access_policy" "des" { 
    key_vault_id = azurerm_key_vault.des_kv.id
    tenant_id    = azurerm_disk_encryption_set.des.identity.0.tenant_id
    object_id    = azurerm_disk_encryption_set.des.identity.0.principal_id

    key_permissions = [
        "get",
        "wrapKey",
        "unwrapKey"
    ]
}