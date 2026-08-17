variable "subscription_id" {
  type        = string
  description = "Existing subscription UUID being onboarded."

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id))
    error_message = "subscription_id must be a UUID."
  }
}

variable "application_name" {
  type        = string
  description = "Short workload name."
}

variable "owner" {
  type        = string
  description = "Accountable owner email address."
}

variable "cost_center" {
  type        = string
  description = "Billing cost center."
}

variable "environment" {
  type        = string
  description = "Workload lifecycle environment."

  validation {
    condition     = contains(["dev", "test", "stage", "prod", "sandbox"], var.environment)
    error_message = "environment must be dev, test, stage, prod, or sandbox."
  }
}

variable "data_classification" {
  type        = string
  description = "Highest permitted data classification."

  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Unsupported data classification."
  }
}

variable "connectivity_profile" {
  type        = string
  description = "Network integration contract."
}

variable "monthly_budget" {
  type        = number
  description = "Monthly budget in the subscription billing currency."
}

variable "budget_start_date" {
  type        = string
  description = "Budget start date."
}

variable "budget_contact_emails" {
  type        = list(string)
  description = "Recipients for budget alerts."
}

variable "expiration_date" {
  type        = string
  description = "RFC3339 workload expiration and budget end date."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Central operations workspace receiving Activity Logs."
}

variable "role_assignments" {
  type = list(object({
    principal_id         = string
    principal_type       = optional(string, "Group")
    role_definition_name = optional(string, "Contributor")
  }))
  default     = []
  description = "Baseline workload access."
}

variable "additional_tags" {
  type        = map(string)
  default     = {}
  description = "Optional non-governance tags. Mandatory values take precedence."
}
