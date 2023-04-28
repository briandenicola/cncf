resource "azurerm_key_vault" "this" {
  name                       = local.kv_name
  resource_group_name        = azurerm_resource_group.this.name
  location                   = azurerm_resource_group.this.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  enable_rbac_authorization  = true

  sku_name = "standard"

  network_acls {
    bypass                    = "AzureServices"
    default_action            = "Allow"
  }

}

resource "azurerm_key_vault_secret" "postgresql_user" {
  name         = "postgres-user"
  value        = "${var.postgresql_user_name}"
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_key_vault_secret" "postgresql_password" {
  name         = "postgres-password"
  value        = "${random_password.postgresql_user_password.result}"
  key_vault_id = azurerm_key_vault.this.id
}