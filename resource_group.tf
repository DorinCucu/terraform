resource "azurerm_resource_group" "rg" {
  name     = "vm_rg"
  location = local.location
  tags     = local.tags
}