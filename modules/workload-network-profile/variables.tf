variable "profile" {
  type        = string
  description = "Network integration profile selected by the workload owner."

  validation {
    condition     = contains(["isolated", "corp", "online"], var.profile)
    error_message = "Network profile must be isolated, corp, or online."
  }
}
