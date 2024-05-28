output "AKS_RESOURCE_GROUP" {
    value = module.cluster.AKS_RESOURCE_GROUP #azurerm_kubernetes_cluster.this.resource_group_name
    sensitive = false
}

output "AKS_CLUSTER_NAME" {
    value = module.cluster.AKS_CLUSTER_NAME #azurerm_kubernetes_cluster.this.name
    sensitive = false
}

output "APP_INSIGHTS_CONNECTION_STRING" {
    value = module.cluster.APP_INSIGHTS_CONNECTION_STRING #azurerm_application_insights.this.connection_string
    sensitive =  true
}