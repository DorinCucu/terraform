resource "azurerm_virtual_network" "vm_vnet" {
  name                = "vm_vnet"
  address_space       = local.address_prefix
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vm_vnet.name
  address_prefixes     = local.address_prefix
}

resource "azurerm_network_interface" "vm_nics" {
  count               = var.vm_count
  name                = "nic-vm-${count.index + 1}"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "vm_ip_setup"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_ips[count.index].id
  }
}

resource "azurerm_public_ip" "vm_ips" {
  count               = var.vm_count
  name                = "public-ip-${count.index + 1}"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}
