resource "azapi_resource" "flux_install" {
  depends_on = [
    azurerm_kubernetes_cluster.this,
    azurerm_kubernetes_cluster_node_pool.default_app_node_pool
  ]

  type      = "Microsoft.KubernetesConfiguration/extensions@2021-09-01"
  name      = "flux"
  parent_id = azurerm_kubernetes_cluster.this.id

  body = jsonencode({
    properties = {
      extensionType           = "microsoft.flux"
      autoUpgradeMinorVersion = true
    }
  })
}

resource "azapi_resource" "flux_config" {
  depends_on = [
    azapi_resource.flux_install
  ]

  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2022-03-01"
  name      = "aks-flux-extension"
  parent_id = azurerm_kubernetes_cluster.this.id

  body = jsonencode({
    properties : {
      scope      = "cluster"
      namespace  = "flux-system"
      sourceKind = "GitRepository"
      suspend    = false
      gitRepository = {
        url                   = local.flux_repository
        timeoutInSeconds      = 600
        syncIntervalInSeconds = 300
        repositoryRef = {
          branch = "main"
        }
      }
      kustomizations : {
        istio-crd = {
          path                   = local.istio_crd_path
          dependsOn              = []
          timeoutInSeconds       = 600
          syncIntervalInSeconds  = 120
          retryIntervalInSeconds = 300
          prune                  = true
        }
        istio-cfg = {
          path                   = local.istio_cfg_path
          dependsOn              = [
            "istio-crd"
          ]
          timeoutInSeconds       = 600
          syncIntervalInSeconds  = 120
          retryIntervalInSeconds = 300
          prune                  = true
        }
        istio-gw = {
          path                   = local.istio_gw_path
          dependsOn              = [
            "istio-cfg"
          ]
          timeoutInSeconds       = 600
          syncIntervalInSeconds  = 120
          retryIntervalInSeconds = 300
          prune                  = true
        }
        apps = {
          path                   = local.app_path
          dependsOn              = [
            "istio-cfg"
          ]
          timeoutInSeconds       = 600
          syncIntervalInSeconds  = 120
          retryIntervalInSeconds = 300
          prune                  = true
        }
      }
    }
  })
}