resource "azurerm_public_ip" "hashibiz-pubip" {
  count                        = "${var.count}"
  name                         = "hashibiz-vm${count.index + 1}-pubip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "dynamic"

  #tags {
  #    environment = "Terraform Demo"
  #}
}

resource "azurerm_network_interface" "hashibiz-nic" {
  count               = "${var.count}"
  name                = "hashibiz-vm${count.index + 1}-nic"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "hashibiz-vm${count.index + 1}-nic-cfg"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.hashibiz-pubip.*.id[count.index]}"
  }

  #tags {
  #  environment = "Terraform Demo"
  #}
}

#resource "azurerm_managed_disk" "hashibiz-disk" {
#  count                = "${var.count}"
#  name                 = "hashibiz-vm${count.index + 1}-disk"
#  location             = "${var.location}"
#  resource_group_name  = "${var.resource_group_name}"
#  storage_account_type = "Premium_LRS"
#  create_option        = "Empty"
#  disk_size_gb         = "30"
#}

resource "azurerm_virtual_machine" "hashibiz-vm" {
  count                         = "${var.count}"
  name                          = "hashibiz-vm${count.index + 1}"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  availability_set_id           = "${var.availability_set_id}"
  network_interface_ids         = ["${azurerm_network_interface.hashibiz-nic.*.id[count.index]}"]
  vm_size                       = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  # delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "hashibiz-vm${count.index + 1}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }
  os_profile {
    computer_name  = "hashibiz-vm${count.index + 1}"
    admin_username = "azureuser"
  }
  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "${file("./id_rsa.pub")}"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "wget https://github.com/gohugoio/hugo/releases/download/v0.42.2/hugo_0.42.2_Linux-64bit.deb",
      "sudo dpkg -i hugo_0.42.2_Linux-64bit.deb",
      "hugo version",
    ]

    connection {
      type        = "ssh"
      user        = "azureuser"
      private_key = "${file("./id_rsa.ppk")}"
    }
  }

  #tags {
  #  environment = "Terraform Demo"
  #}
}
