resource "azurerm_linux_virtual_machine" "vm" {
  depends_on                      = [random_password.vm_password]
  count                           = var.vm_count
  name                            = "vm-${count.index + 1}"
  tags                            = local.tags
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = local.location
  size                            = var.vm_size
  disable_password_authentication = false
  admin_username                  = local.vm_user
  admin_password                  = random_password.vm_password[count.index].result
  network_interface_ids = [
    azurerm_network_interface.vm_nics[count.index].id,
  ]
  admin_ssh_key {
    username   = local.vm_user
    public_key = file("${local.ssh_path}vm_key.pub")
  }
  custom_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y iputils-ping
              EOF
  )
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = var.vm_image
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}