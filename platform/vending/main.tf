resource "terraform_data" "request_contract" {
  input = local.request

  lifecycle {
    precondition {
      condition     = contains(["corp", "online", "local", "sandbox"], local.request.management_group_destination)
      error_message = "Unsupported landing-zone management group destination."
    }

    precondition {
      condition     = local.request.monthly_budget > 0
      error_message = "A positive monthly budget is required."
    }
  }
}

resource "azurerm_management_group_subscription_association" "workload" {
  management_group_id = "/providers/Microsoft.Management/managementGroups/${local.request.management_group_destination}"
  subscription_id     = "/subscriptions/${local.request.subscription_id}"

  depends_on = [terraform_data.request_contract]
}

module "subscription_profile" {
  source = "../../modules/subscription-profile"

  subscription_id            = local.request.subscription_id
  application_name           = local.request.application_name
  owner                      = local.request.owner
  cost_center                = local.request.cost_center
  environment                = local.request.environment
  data_classification        = local.request.data_classification
  connectivity_profile       = local.request.connectivity_profile
  monthly_budget             = local.request.monthly_budget
  budget_start_date          = local.request.budget_start_date
  budget_contact_emails      = local.request.budget_contact_emails
  expiration_date            = local.request.expiration_date
  log_analytics_workspace_id = local.request.log_analytics_workspace_id
  role_assignments           = try(local.request.role_assignments, [])
  additional_tags            = try(local.request.additional_tags, {})

  depends_on = [azurerm_management_group_subscription_association.workload]
}
