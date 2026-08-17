variable "default_location" {
  description = "Azure region used by policy assignments with managed identities."
  type        = string
  default     = "eastus2"
}

variable "parent_management_group_id" {
  description = "Existing parent management group name, without the resource ID prefix. Null uses the tenant root."
  type        = string
  default     = null
  nullable    = true
}

variable "platform_subscription_ids" {
  description = "Existing subscriptions to place under the corresponding platform management group."
  type = object({
    connectivity = optional(string)
    identity     = optional(string)
    management   = optional(string)
    security     = optional(string)
  })
  default = {}

  validation {
    condition = alltrue([
      for id in values(var.platform_subscription_ids) :
      id == null || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Each platform subscription ID must be a UUID."
  }
}

variable "additional_subscription_placement" {
  description = "Existing workload subscriptions to enroll into an ALZ management group."
  type = map(object({
    subscription_id       = string
    management_group_name = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for placement in values(var.additional_subscription_placement) :
      contains(["corp", "online", "local", "sandbox", "decommissioned"], placement.management_group_name)
    ])
    error_message = "Workload subscriptions must target corp, online, local, sandbox, or decommissioned."
  }
}

variable "manage_tenant_hierarchy_settings" {
  description = "Whether the factory should secure tenant hierarchy creation and set Sandbox as the default group."
  type        = bool
  default     = false
}

variable "enable_telemetry" {
  description = "Enable anonymous telemetry in the Microsoft ALZ module."
  type        = bool
  default     = false
}
