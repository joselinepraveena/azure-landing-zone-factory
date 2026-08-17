variable "subscription_id" {
  type        = string
  description = "Target subscription UUID."
}

variable "assignments" {
  description = "Subscription role assignments. Group principals are preferred."
  type = list(object({
    principal_id         = string
    principal_type       = optional(string, "Group")
    role_definition_name = optional(string, "Contributor")
  }))
  default = []

  validation {
    condition = alltrue([
      for assignment in var.assignments :
      contains(["Group", "ServicePrincipal", "User"], assignment.principal_type)
    ])
    error_message = "principal_type must be Group, ServicePrincipal, or User."
  }

  validation {
    condition = alltrue([
      for assignment in var.assignments :
      !contains(["Owner", "User Access Administrator", "Role Based Access Control Administrator"], assignment.role_definition_name)
    ])
    error_message = "Factory requests cannot grant privileged role-assignment administration roles."
  }
}
