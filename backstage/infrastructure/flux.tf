resource "azapi_resource" "flux_install" {
  depends_on = [
    azurerm_kubernetes_cluster.this
  ]

  type      = "Microsoft.KubernetesConfiguration/extensions@2022-11-01"
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

  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2022-11-01"
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
        cluster-config = {
          path                   = local.app_path
          timeoutInSeconds       = 600
          syncIntervalInSeconds  = 120
          retryIntervalInSeconds = 300
          prune                  = true
        }
      }
    }
  })
}