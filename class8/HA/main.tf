provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vault-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "vault-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "vault-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow_ssh"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow_http" {
  name                        = "allow_http"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8200"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "public_ip_lb" {
  name                = "vault-public-ip-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "public_ip_vm" {
  count               = var.vm_count
  name                = "vault-public-ip-vm-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "vault-nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_vm[count.index].id
  }
}

resource "azurerm_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "vault-vm-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  vm_size = "Standard_B2ms"

  storage_os_disk {
    name              = "vault-os-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "vault-${count.index}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_lb" "lb" {
  name                = "vault-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.public_ip_lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "bap" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "VaultBackEndPool"
}

resource "azurerm_lb_probe" "lb_probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "HttpProbe"
  port            = 8200

  protocol            = "Http"
  request_path        = "/v1/sys/health"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "lbrule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "VaultHTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 8200
  backend_port                   = 8200
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bap.id]
  probe_id                       = azurerm_lb_probe.lb_probe.id
}

resource "azurerm_virtual_machine_extension" "vm_extension" {
  count                = var.vm_count
  name                 = "vault-${count.index}"
  virtual_machine_id   = azurerm_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings = <<SETTINGS
{
    "commandToExecute": "echo 'vault_installed'"
}
SETTINGS
}