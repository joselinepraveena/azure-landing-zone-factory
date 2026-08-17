variable "name" {
  type        = string
  description = "Diagnostic setting name."
}

variable "subscription_id" {
  type        = string
  description = "Target subscription UUID."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Central Log Analytics workspace resource ID."

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    error_message = "A complete Log Analytics workspace resource ID is required."
  }
}
