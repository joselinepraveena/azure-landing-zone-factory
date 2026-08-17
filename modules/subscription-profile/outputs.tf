output "profile" {
  description = "Machine-readable result returned to the workload owner."
  value = {
    subscription_id        = var.subscription_id
    budget_id              = module.budget.resource_id
    diagnostic_setting_id  = module.diagnostics.resource_id
    role_assignment_ids    = module.role_assignments.resource_ids
    connectivity           = module.network_profile.profile
    applied_mandatory_tags = local.mandatory_tags
  }
}
