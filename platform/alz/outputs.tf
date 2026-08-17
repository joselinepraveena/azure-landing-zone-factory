output "management_group_resource_ids" {
  description = "Management group resource IDs created by the ALZ pattern."
  value       = module.alz.management_group_resource_ids
}

output "policy_assignment_resource_ids" {
  description = "Policy assignment resource IDs created by the ALZ pattern."
  value       = module.alz.policy_assignment_resource_ids
}
