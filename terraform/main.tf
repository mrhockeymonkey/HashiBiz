# Configure the Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

# Create a resource group
resource "azurerm_resource_group" "hashibiz-prod" {
  name     = "hashibiz-prod"
  location = "uksouth"
}

resource "azurerm_virtual_network" "hashibiz-net" {
  name                = "hashibiz-net"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.hashibiz-prod.name}"

  #tags {
  #    environment = "Terraform Demo"
  #}
}

resource "azurerm_subnet" "hashibiz-web" {
  name                 = "hashibiz-web"
  resource_group_name  = "${azurerm_resource_group.hashibiz-prod.name}"
  virtual_network_name = "${azurerm_virtual_network.hashibiz-net.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_security_group" "hashibiz-netsec" {
  name                = "hashibiz-netsec"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.hashibiz-prod.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  #tags {
  #  environment = "Terraform Demo"
  #}
}

resource "azurerm_availability_set" "hashibiz-avset" {
  name                         = "hashibiz-avset"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.hashibiz-prod.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

module "hashibiz-vm" {
  source              = "./hashibiz-vm"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.hashibiz-prod.name}"
  subnet_id           = "${azurerm_subnet.hashibiz-web.id}"
  availability_set_id = "${azurerm_availability_set.hashibiz-avset.id}"
  count               = 1
}
