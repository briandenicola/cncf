resource "random_password" "postgresql_user_password" {
  length           = 25
  special          = false
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                   = local.sql_name
  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  delegated_subnet_id    = azurerm_subnet.sql.id
  version                = "12"
  administrator_login    = var.postgresql_user_name
  administrator_password = random_password.postgresql_user_password.result
  private_dns_zone_id    = azurerm_private_dns_zone.privatelink_postgres_database_azure_com.id
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2ds_v4"
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name                = var.postgresql_database_name
  server_id           = azurerm_postgresql_flexible_server.this.id
  collation           = "en_US.utf8"
  charset             = "utf8"
}
