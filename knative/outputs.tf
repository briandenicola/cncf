# output "RESOURCE_GROUP" {
#     value = azurerm_resource_group.this.name
#     sensitive = false
# }

output "AKS_RESOURCE_GROUP" {
    value = module.cluster.AKS_RESOURCE_GROUP
    sensitive = false
}

output "AKS_CLUSTER_NAME" {
    value = module.cluster.AKS_CLUSTER_NAME
    sensitive = false
}

output "APP_NAME" {
    value = local.resource_name
    sensitive = false
}
