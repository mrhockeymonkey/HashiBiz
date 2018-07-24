output "names" {
  description = "the name of the vm"
  value       = ["${azurerm_virtual_machine.hashibiz-vm.*.name}"]
}

output "public_ips" {
  description = "The public ip address allocated for the vm."
  value       = ["${azurerm_public_ip.hashibiz-pubip.*.ip_address}"]
}
