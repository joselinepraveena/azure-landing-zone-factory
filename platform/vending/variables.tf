variable "request_file" {
  type        = string
  description = "Path to a validated workload vending request JSON file."

  validation {
    condition     = endswith(var.request_file, ".json") && fileexists(var.request_file)
    error_message = "request_file must identify an existing JSON file."
  }
}
