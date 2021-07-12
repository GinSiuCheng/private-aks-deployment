output log_analytics_workspace_id {
    description = "Log Analytics Workspace Id"
    value       = azurerm_log_analytics_workspace.this.id 
}