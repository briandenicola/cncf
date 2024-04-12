resource "azurerm_kubernetes_cluster" "this" {
  lifecycle {
    ignore_changes = [
      default_node_pool.0.node_count,
    ]
  }

  name                            = local.aks_name
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  node_resource_group             = "${local.resource_name}_k8s_nodes_rg"
  dns_prefix                      = local.aks_name
  sku_tier                        = "Free"
  oidc_issuer_enabled             = true
  open_service_mesh_enabled       = false
  azure_policy_enabled            = true
  workload_identity_enabled       = true

  api_server_access_profile {
    authorized_ip_ranges          = ["${chomp(data.http.myip.response_body)}/32"]
  }

  azure_active_directory_role_based_access_control {
    managed                       = true
    azure_rbac_enabled            = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  identity {
    type                          = "UserAssigned"
    identity_ids                  = [azurerm_user_assigned_identity.aks_identity.id]
  }

  kubelet_identity {
    client_id                     = azurerm_user_assigned_identity.aks_kubelet_identity.client_id
    object_id                     = azurerm_user_assigned_identity.aks_kubelet_identity.principal_id
    user_assigned_identity_id     = azurerm_user_assigned_identity.aks_kubelet_identity.id
  }

  default_node_pool {
    name                = "default"
    node_count          = 2
    vm_size             = "Standard_DS2_v2"
    os_disk_size_gb     = 127
    vnet_subnet_id      = azurerm_subnet.this.id
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = false
    max_pods            = 250
  }

  network_profile {
    dns_service_ip     = "100.${random_integer.services_cidr.id}.0.10"
    service_cidr       = "100.${random_integer.services_cidr.id}.0.0/16"
    network_plugin     = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku  = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

}
