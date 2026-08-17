variable "name" {
  type        = string
  description = "Budget name."
}

variable "subscription_id" {
  type        = string
  description = "Target subscription UUID."
}

variable "amount" {
  type        = number
  description = "Monthly budget amount in the subscription billing currency."

  validation {
    condition     = var.amount > 0
    error_message = "Budget amount must be greater than zero."
  }
}

variable "start_date" {
  type        = string
  description = "Budget start date at 00:00 UTC on the first day of a month."
}

variable "end_date" {
  type        = string
  description = "Budget end date."
}

variable "contact_emails" {
  type        = map(list(string))
  description = "Notification threshold mapped to contact email addresses."

  validation {
    condition = alltrue([
      for threshold in keys(var.contact_emails) :
      tonumber(threshold) > 0 && tonumber(threshold) <= 1000
    ])
    error_message = "Budget thresholds must be between 1 and 1000."
  }
}
