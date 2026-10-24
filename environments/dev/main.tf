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
  address_space = ["10.10.0.0/16"]

  subnets = {
    app  = { address_prefixes = ["10.10.1.0/24"] }
    data = { address_prefixes = ["10.10.2.0/24"] }
  }

  tags = local.tags
}