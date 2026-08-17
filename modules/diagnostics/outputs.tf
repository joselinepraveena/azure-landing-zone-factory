output "resource_id" {
  description = "Subscription Activity Log diagnostic setting resource ID."
  value       = azurerm_monitor_diagnostic_setting.activity_log.id
}
