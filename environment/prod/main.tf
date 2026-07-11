module "network" {
  source = "../../modules/network"

  name_prefix      = var.name_prefix
  azs              = var.azs
  ssh_key_name     = var.ssh_key_name
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

module "data" {
  source = "../../modules/data"

  db_name     = var.db_name
  name_prefix = var.name_prefix
  compute_az  = var.azs[0]

  db_allocated_storage     = var.db_allocated_storage
  db_backup_retention_days = var.db_backup_retention_days

  private_subnet_ids = module.network.private_subnet_ids
  rds_sg_id          = module.network.rds_sg_id
}



