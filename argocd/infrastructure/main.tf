resource "random_id" "this" {
  byte_length = 2
}

resource "random_pet" "this" {
  length    = 1
  separator = ""
}

locals {
  location              =  var.region
  resource_name         = "${random_pet.this.id}-${random_id.this.dec}"
  workload_identity     = "${local.resource_name}-app-identity"
  authorized_ip_ranges = ["${chomp(data.http.myip.response_body)}/32"]
}

resource "azurerm_resource_group" "this" {
  name     = "${local.resource_name}_rg"
  location = local.location

  tags = {
    Application = var.tags
    Components  = "aks; argocd"
    DeployedOn  = timestamp()
  }
}
