locals {
  mandatory_tags = {
    Application        = var.application_name
    CostCenter         = var.cost_center
    DataClassification = var.data_classification
    Environment        = var.environment
    ExpirationDate     = var.expiration_date
    ManagedBy          = "azure-landing-zone-factory"
    Owner              = var.owner
  }
}

resource "azapi_update_resource" "subscription_tags" {
  type      = "Microsoft.Resources/tags@2021-04-01"
  name      = "default"
  parent_id = "/subscriptions/${var.subscription_id}"

  body = {
    properties = {
      tags = merge(var.additional_tags, local.mandatory_tags)
    }
  }
}

module "budget" {
  source = "../budget"

  name            = "${var.application_name}-${var.environment}-monthly"
  subscription_id = var.subscription_id
  amount          = var.monthly_budget
  start_date      = var.budget_start_date
  end_date        = var.expiration_date
  contact_emails = {
    "80"  = var.budget_contact_emails
    "100" = var.budget_contact_emails
  }
}

module "role_assignments" {
  source = "../role-assignments"

  subscription_id = var.subscription_id
  assignments     = var.role_assignments
}

module "diagnostics" {
  source = "../diagnostics"

  name                       = "platform-activity-logs"
  subscription_id            = var.subscription_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

module "network_profile" {
  source = "../workload-network-profile"

  profile = var.connectivity_profile
}
