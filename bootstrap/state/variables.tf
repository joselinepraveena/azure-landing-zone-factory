variable "subscription_id" {
  type        = string
  description = "Subscription that hosts Terraform state."
}

variable "name_prefix" {
  type        = string
  description = "Globally unique naming seed."
  default     = "alzf"
}

variable "location" {
  type        = string
  description = "Azure region for state resources."
  default     = "eastus2"
}

variable "replication_type" {
  type        = string
  description = "Storage redundancy. Use GRS for production."
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS"], var.replication_type)
    error_message = "replication_type must be LRS, ZRS, GRS, or GZRS."
  }
}

variable "tags" {
  type        = map(string)
  description = "Bootstrap resource tags."
  default = {
    ManagedBy = "azure-landing-zone-factory"
    Purpose   = "terraform-state"
  }
}
