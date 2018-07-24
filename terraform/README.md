SSH Keys:
used putty gen to generate key > save private as id_rsa.ppk and public as id_rsa.pub 

Useful links:

Consul module for Terraform - https://registry.terraform.io/modules/hashicorp/consul/azurerm/0.0.5




isues vm disk are not deleted? have to do so manually???


Error: Error applying plan:

3 error(s) occurred:

* module.hashibiz-vm.azurerm_virtual_machine.hashibiz-vm[2]: 1 error(s) occurred:

* azurerm_virtual_machine.hashibiz-vm.2: Long running operation terminated with status 'Failed': Code="ConflictingUserInput" Message="Disk hashibiz-disk already exists in resource group HASHIBIZ-PROD. Only CreateOption.Attach is supported."
* module.hashibiz-vm.azurerm_virtual_machine.hashibiz-vm[0]: 1 error(s) occurred:

* azurerm_virtual_machine.hashibiz-vm.0: Long running operation terminated with status 'Failed': Code="ConflictingUserInput" Message="Disk hashibiz-disk already exists in resource group HASHIBIZ-PROD. Only CreateOption.Attach is supported."
* module.hashibiz-vm.azurerm_virtual_machine.hashibiz-vm[1]: 1 error(s) occurred:

* azurerm_virtual_machine.hashibiz-vm.1: Long running operation terminated with status 'Failed': Code="ConflictingUserInput" Message="Disk hashibiz-disk already exists in resource group HASHIBIZ-PROD. Only CreateOption.Attach is supported."

Terraform does not automatically rollback in the face of errors.
Instead, your Terraform state file has been partially updated with
any resources that successfully completed. Please address the error
above and apply again to incrementally change your infrastructure.
