output "AKS_RESOURCE_GROUP" {
    value = azurerm_kubernetes_cluster.this.resource_group_name
    sensitive = false
}

output "AKS_CLUSTER_NAME" {
    value = azurerm_kubernetes_cluster.this.name
    sensitive = false
}

output "APP_INSIGHTS_CONNECTION_STRING" {
    value = azurerm_application_insights.this.connection_string
    sensitive =  true
}