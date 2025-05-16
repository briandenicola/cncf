module "cluster" {
  source               = "../../module"
  region               = var.region
  authorized_ip_ranges = local.authorized_ip_ranges
  resource_name        = local.resource_name
  public_key_openssh   = tls_private_key.rsa.public_key_openssh
  tags                 = var.tags
  kubernetes_version   = "1.31"
  sdlc_environment     = "dev"
  vm_sku               = "Standard_D4d_v5"
  node_count           = "3"
  zones                = ["1"]
}
