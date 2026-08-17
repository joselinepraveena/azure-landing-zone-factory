data "azapi_client_config" "current" {}

locals {
  parent_management_group_id = coalesce(
    var.parent_management_group_id,
    data.azapi_client_config.current.tenant_id
  )

  platform_subscriptions = {
    for name, subscription_id in var.platform_subscription_ids :
    name => {
      subscription_id       = subscription_id
      management_group_name = name
    }
    if subscription_id != null
  }
}

module "alz" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "0.21.0"

  architecture_name  = "alz"
  location           = var.default_location
  parent_resource_id = local.parent_management_group_id

  subscription_placement = merge(
    local.platform_subscriptions,
    var.additional_subscription_placement
  )

  management_group_hierarchy_settings = var.manage_tenant_hierarchy_settings ? {
    default_management_group_name            = "sandbox"
    require_authorization_for_group_creation = true
    update_existing                          = true
  } : null

  subscription_placement_destroy_behavior = "parent"
  enable_telemetry                        = var.enable_telemetry
}
