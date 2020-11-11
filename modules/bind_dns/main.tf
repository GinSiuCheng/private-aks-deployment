# Bind DNS TF Module
# Subnet for BIND
resource "azurerm_subnet" "bind" {
    name                        = "${var.bind_dns_name}-subnet"
    resource_group_name         = var.resource_group_name
    virtual_network_name        = var.bind_vnet_name
    address_prefixes            = [var.bind_dns_addr_prefix]
} 

# NIC for BIND DNS 
resource "azurerm_network_interface" "bind" { 
    name                              = "${var.bind_dns_name}-nic"
    location                          = var.location
    resource_group_name               = var.resource_group_name
    
    ip_configuration { 
        name                          = "configuration"
        subnet_id                     = azurerm_subnet.bind.id 
        private_ip_address_allocation = "Static"
        private_ip_address            = var.bind_private_ip_addr
    }
}

# NSG for BIND DNS Subnet 
resource "azurerm_network_security_group" "bind" { 
    name                        = "${var.bind_dns_name}-nsg"
    location                    = var.location
    resource_group_name         = var.resource_group_name
}

resource "azurerm_network_security_rule" "bind_ssh" { 
    name                            = "${var.bind_dns_name}-ssh"
    priority                        = 100
    direction                       = "Inbound"
    access                          = "Allow"
    protocol                        = "Tcp"
    source_port_range               = "*"
    destination_port_range          = "22"
    source_address_prefixes         = var.bind_ssh_source_addr_prefixes 
    destination_address_prefix      = azurerm_subnet.bind.address_prefixes[0]
    resource_group_name             = var.resource_group_name
    network_security_group_name     = azurerm_network_security_group.bind.name
}

resource "azurerm_subnet_network_security_group_association" "bind" { 
    subnet_id                   = azurerm_subnet.bind.id
    network_security_group_id   = azurerm_network_security_group.bind.id 
}

# Virtual Machine for BIND 
resource "azurerm_linux_virtual_machine" "bind" {
    name                        = var.bind_dns_name 
    resource_group_name         = var.resource_group_name
    location                    = var.location
    size                        = var.bind_vm_size
    admin_username              = var.bind_admin_username
    network_interface_ids = [ 
        azurerm_network_interface.bind.id
    ] 

    admin_ssh_key { 
        username                = var.bind_admin_username
        public_key              = file(var.bind_pub_key_name)
    }

    os_disk { 
        caching                 = "ReadWrite"
        storage_account_type    = "Standard_LRS"
    }

    source_image_reference { 
        publisher               = "Canonical"
        offer                   = "UbuntuServer"
        sku                     = "16.04-LTS"
        version                 = "latest"
    }
    
    tags                        = var.tags 
}

# Install BIND with custom script extension 
resource "azurerm_virtual_machine_extension" "bind_install" { 
    name                        = "${var.bind_dns_name}_vm_extension"
    virtual_machine_id          = azurerm_linux_virtual_machine.bind.id
    publisher                   = "Microsoft.Azure.Extensions"
    type                        = "CustomScript"
    type_handler_version        = "2.0"

    settings = <<SETTINGS
    {
        "script":"${filebase64("modules/bind_dns/bind_install.sh")}"
    }
    SETTINGS
}