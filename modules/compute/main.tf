resource "azurerm_public_ip" "lb" {
  name                = "pip-lb-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_lb" "this" {
  name                = "lb-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  name            = "backend-pool"
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_lb_probe" "http" {
  name                = "http-probe"
  loadbalancer_id     = azurerm_lb.this.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "http" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this.id]
  probe_id                       = azurerm_lb_probe.http.id
  disable_outbound_snat          = true
}

# Lets servers reach the internet (to install nginx) without having public IPs
resource "azurerm_lb_outbound_rule" "this" {
  name                    = "outbound"
  loadbalancer_id         = azurerm_lb.this.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id

  frontend_ip_configuration {
    name = "public-frontend"
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                            = "vmss-${var.project}-${var.environment}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  sku                             = var.vm_sku
  zones                           = ["2"]
  instances                       = var.instance_count
  admin_username                  = "azureuser"
  disable_password_authentication = true
  custom_data                     = base64encode(file("${path.module}/cloud-init.yaml"))
  tags                            = var.tags

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.this.id]
    }
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [azurerm_lb_rule.http, azurerm_lb_outbound_rule.this]
}