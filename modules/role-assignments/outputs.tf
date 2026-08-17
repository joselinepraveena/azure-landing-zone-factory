output "resource_ids" {
  description = "Role assignment resource IDs keyed by principal and role."
  value       = { for key, assignment in azurerm_role_assignment.this : key => assignment.id }
}
