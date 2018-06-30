# required variables
variable "location" {
  description = "The location that the vm/s will run in (e.g. UK South)"
}

variable "resource_group_name" {
  description = "The name of the resource group that the vm/s resources will run in"
}

variable "subnet_id" {
  description = "The id of the subnet to deploy the vm/s into"
}

variable "availability_set_id" {
  description = "The id of the availability set to place the vm/s into"
}

# optional variable
variable "count" {
  description = "The number of vm/s to create with the defined variables"
  default     = 1
}
