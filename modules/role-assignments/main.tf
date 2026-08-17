resource "azurerm_role_assignment" "this" {
  for_each = {
    for assignment in var.assignments :
    "${assignment.principal_id}:${assignment.role_definition_name}" => assignment
  }

  scope                = "/subscriptions/${var.subscription_id}"
  principal_id         = each.value.principal_id
  role_definition_name = each.value.role_definition_name
  principal_type       = each.value.principal_type
  description          = "Managed by the Azure Landing Zone Factory"
}
