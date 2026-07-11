module "network" {
  source = "../../modules/network"

  name_prefix      = var.name_prefix
  azs              = var.azs
  ssh_key_name     = var.ssh_key_name
  ssh_allowed_cidr = var.ssh_allowed_cidr
}


