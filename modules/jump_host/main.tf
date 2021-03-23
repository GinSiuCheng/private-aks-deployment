# Jump Host TF Module
# Subnet for jump_host
resource "azurerm_subnet" "jump_host" {
    name                        = "${var.jump_host_name}-subnet"
    resource_group_name         = var.resource_group_name
    virtual_network_name        = var.jump_host_vnet_name
    address_prefixes            = [var.jump_host_addr_prefix]
} 

# NIC for jump_host 
resource "azurerm_network_interface" "jump_host" { 
    name                              = "${var.jump_host_name}-nic"
    location                          = var.location
    resource_group_name               = var.resource_group_name
    
    ip_configuration { 
        name                          = "configuration"
        subnet_id                     = azurerm_subnet.jump_host.id 
        private_ip_address_allocation = "Static"
        private_ip_address            = var.jump_host_private_ip_addr
    }
}

# NSG for jump_host Subnet 
resource "azurerm_network_security_group" "jump_host" { 
    name                        = "${var.jump_host_name}-nsg"
    location                    = var.location
    resource_group_name         = var.resource_group_name
}

resource "azurerm_network_security_rule" "jump_host_ssh" { 
    name                            = "${var.jump_host_name}-ssh"
    priority                        = 100
    direction                       = "Inbound"
    access                          = "Allow"
    protocol                        = "Tcp"
    source_port_range               = "*"
    destination_port_range          = "22"
    source_address_prefixes         = var.jump_host_ssh_source_addr_prefixes 
    destination_address_prefix      = azurerm_subnet.jump_host.address_prefixes[0]
    resource_group_name             = var.resource_group_name
    network_security_group_name     = azurerm_network_security_group.jump_host.name
}

resource "azurerm_subnet_network_security_group_association" "jump_host" { 
    subnet_id                   = azurerm_subnet.jump_host.id
    network_security_group_id   = azurerm_network_security_group.jump_host.id 
}

# Virtual Machine for jump_host 
resource "azurerm_linux_virtual_machine" "jump_host" {
    name                        = var.jump_host_name 
    resource_group_name         = var.resource_group_name
    location                    = var.location
    size                        = var.jump_host_vm_size
    admin_username              = var.jump_host_admin_username
    network_interface_ids = [ 
        azurerm_network_interface.jump_host.id
    ] 

    admin_ssh_key { 
        username                = var.jump_host_admin_username
        public_key              = file(var.jump_host_pub_key_name)
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

# Install jump_host with custom script extension 
resource "azurerm_virtual_machine_extension" "jump_host_install" { 
    name                        = "${var.jump_host_name}_vm_extension"
    virtual_machine_id          = azurerm_linux_virtual_machine.jump_host.id
    publisher                   = "Microsoft.Azure.Extensions"
    type                        = "CustomScript"
    type_handler_version        = "2.0"

    settings = <<SETTINGS
    {
        "script":"${filebase64("modules/jump_host/tools_install.sh")}"
    }
    SETTINGS
}