resource "random_id" "this" {
  byte_length = 2
}

resource "random_pet" "this" {
  length    = 1
  separator = ""
}

locals {
  resource_name          = "${random_pet.this.id}-${random_id.this.dec}"
  authorized_ip_ranges   = "${chomp(data.http.myip.response_body)}/32"
  tags                   = "Knative Demo"
}

module "cluster" {
  source               = "../module"
  region               = var.region
  authorized_ip_ranges = local.authorized_ip_ranges
  resource_name        = local.resource_name
  public_key_openssh   = tls_private_key.rsa.public_key_openssh
  tags                 = local.tags
  kubernetes_version   = "1.27.7"
  sdlc_environment     = "dev"
  vm_sku               = "Standard_D16as_v5"
  node_count           = "3"
}

# resource "azurerm_resource_group" "this" {
#   name     = "${local.resource_name}_rg"
#   location = var.region

#   tags = {
#     Application = local.tags
#     Components  = "AKS; Storage; Azure Service Mesh"
#     DeployedOn  = timestamp()
#   }
# }
