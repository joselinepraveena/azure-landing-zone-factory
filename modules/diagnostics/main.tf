locals {
  activity_log_categories = toset([
    "Administrative",
    "Alert",
    "Autoscale",
    "Policy",
    "Recommendation",
    "ResourceHealth",
    "Security",
    "ServiceHealth",
  ])
}

resource "azurerm_monitor_diagnostic_setting" "activity_log" {
  name                       = var.name
  target_resource_id         = "/subscriptions/${var.subscription_id}"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = local.activity_log_categories

    content {
      category = enabled_log.value
    }
  }
}
