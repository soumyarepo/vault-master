variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources in"
  type        = string
}

variable "admin_username" {
  description = "The admin username for the virtual machines"
  type        = string
  default     = "vaultadmin"  # Change this to a compliant username
}

variable "admin_password" {
  description = "The admin password for the virtual machines"
  type        = string
  default     = "Compl3xP@ssw0rd!"  # Ensure this meets the complexity requirements
}

variable "vm_count" {
  description = "Number of virtual machines to create"
  type        = number
  default     = 3
}