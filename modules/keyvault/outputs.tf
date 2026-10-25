output "id" {
  value = azurerm_key_vault.this.id
}

output "name" {
  value = azurerm_key_vault.this.name
}

output "deployer_role_id" {
  value = azurerm_role_assignment.deployer.id
}