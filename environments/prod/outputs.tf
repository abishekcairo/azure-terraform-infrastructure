output "load_balancer_ip" {
  value = module.compute.lb_public_ip
}

output "key_vault_name" {
  value = module.keyvault.name
}

output "database_fqdn" {
  value = module.database.server_fqdn
}