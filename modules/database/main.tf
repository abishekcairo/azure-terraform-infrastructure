resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#%*-_"
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                          = "psql-${var.project}-${var.environment}-${random_string.suffix.result}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "16"
  administrator_login           = "pgadmin"
  administrator_password        = random_password.db.result
  sku_name                      = var.sku_name
  storage_mb                    = 32768
  backup_retention_days         = var.backup_retention_days
  public_network_access_enabled = false
  tags                          = var.tags

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "link-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_endpoint" "postgres" {
  name                = "pe-psql-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-psql"
    private_connection_resource_id = azurerm_postgresql_flexible_server.this.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgres.id]
  }
}

# Store the generated password in Key Vault
resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-admin-password"
  value        = random_password.db.result
  key_vault_id = var.key_vault_id
}