resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "email" {
  name                = "ag-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = "tfalerts"

  email_receiver {
    name          = "owner"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_metric_alert" "cpu_high" {
  name                = "alert-cpu-high-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [var.vmss_id]
  description         = "Average CPU above 80 percent for 5 minutes"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.email.id
  }
}

resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name                       = "diag-keyvault"
  target_resource_id         = var.key_vault_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category_group = "audit"
  }
}