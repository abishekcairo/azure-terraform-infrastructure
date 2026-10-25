locals {
  tags = {
    project     = var.project
    environment = var.environment
    owner       = "abishek"
    managed_by  = "terraform"
  }
}

module "networking" {
  source        = "../../modules/networking"
  project       = var.project
  environment   = var.environment
  location      = var.location
  address_space = ["10.20.0.0/16"]

  subnets = {
    app  = { address_prefixes = ["10.20.1.0/24"] }
    data = { address_prefixes = ["10.20.2.0/24"] }
  }

  tags = local.tags
}

module "keyvault" {
  source                   = "../../modules/keyvault"
  project                  = var.project
  environment              = var.environment
  location                 = module.networking.location
  resource_group_name      = module.networking.resource_group_name
  purge_protection_enabled = true
  tags                     = local.tags
}

module "compute" {
  source              = "../../modules/compute"
  project             = var.project
  environment         = var.environment
  location            = module.networking.location
  resource_group_name = module.networking.resource_group_name
  subnet_id           = module.networking.subnet_ids["app"]
  vm_sku              = "Standard_B2als_v2"
  instance_count      = 2
  ssh_public_key      = var.ssh_public_key
  tags                = local.tags
}

module "database" {
  source                     = "../../modules/database"
  project                    = var.project
  environment                = var.environment
  location                   = module.networking.location
  resource_group_name        = module.networking.resource_group_name
  vnet_id                    = module.networking.vnet_id
  private_endpoint_subnet_id = module.networking.subnet_ids["data"]
  key_vault_id               = module.keyvault.id
  sku_name                   = "B_Standard_B1ms"
  backup_retention_days      = 35
  tags                       = local.tags

  # make sure the deployer can write secrets before the password is stored
  depends_on = [module.keyvault]
}

module "monitoring" {
  source              = "../../modules/monitoring"
  project             = var.project
  environment         = var.environment
  location            = module.networking.location
  resource_group_name = module.networking.resource_group_name
  vmss_id             = module.compute.vmss_id
  key_vault_id        = module.keyvault.id
  alert_email         = var.alert_email
  retention_days      = 90
  tags                = local.tags
}