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
  tags                   = "OpenTelemetry Demo"
}

module "cluster" {
  source               = "../../module"
  region               = var.region
  authorized_ip_ranges = local.authorized_ip_ranges
  resource_name        = local.resource_name
  public_key_openssh   = tls_private_key.rsa.public_key_openssh
  tags                 = local.tags
  kubernetes_version   = "1.28"
  sdlc_environment     = "dev"
  vm_sku               = "Standard_D8as_v5"
  node_count           = "3"
  zones                = ["1"]
}

# resource "azurerm_resource_group" "this" {
#   name     = "${local.resource_name}_rg"
#   location = local.location

#   tags = {
#     Application = "otel-demo"
#     Components  = "aks; otel"
#     DeployedOn  = timestamp()
#   }
# }


