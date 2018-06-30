variable "subscription_id" {
  description = "azure subscription id"
}

variable "client_id" {
  description = "azure service principal user"
}

variable "client_secret" {
  description = "azure service principal password"
}

variable "tenant_id" {
  description = "azure tenant id"
}

variable "location" {
  description = "the location to provision in"
  default     = "uksouth"
}
