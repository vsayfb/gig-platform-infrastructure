module "network" {
  source = "../../modules/network"

  name_prefix      = var.name_prefix
  azs              = var.azs
  ssh_key_name     = var.ssh_key_name
  ssh_allowed_cidr = var.ssh_allowed_cidr
  app_port_range   = var.app_port_range
}

module "data" {
  source = "../../modules/data"

  name_prefix        = var.name_prefix
  private_subnet_ids = module.network.private_subnet_ids
  rds_sg_id          = module.network.rds_sg_id
  compute_az         = var.azs[0]
  db_name            = var.db_name

  db_allocated_storage     = var.db_allocated_storage
  db_backup_retention_days = var.db_backup_retention_days
}

module "compute" {
  source = "../../modules/compute"

  aws_region  = var.aws_region
  name_prefix = var.name_prefix

  vpc_id                 = module.network.vpc_id
  alb_subnet_ids         = module.network.public_subnet_ids
  compute_subnet_id      = module.network.compute_subnet_id
  alb_sg_id              = module.network.alb_sg_id
  private_services_sg_id = module.network.private_services_sg_id
  app_port_range         = var.app_port_range

  rds_secret_read_policy_arn   = module.data.rds_secret_read_policy_arn
  core_sqs_produce_policy_arn  = module.data.core_sqs_produce_policy_arn
  worker_sqs_access_policy_arn = module.data.worker_sqs_access_policy_arn

  ssh_key_name = var.ssh_key_name

  opamp_auth_token_parameter_name = var.grafana_cloud_opamp_auth_token_parameter_name
  opamp_endpoint_parameter_name   = var.grafana_cloud_opamp_endpoint
}


module "observability" {
  source = "../../modules/observability"

  name_prefix                                   = var.name_prefix
  grafana_cloud_opamp_auth_token_parameter_name = var.grafana_cloud_opamp_auth_token_parameter_name
  grafana_cloud_opamp_endpoint                  = var.grafana_cloud_opamp_endpoint
}

module "lambda" {
  source = "../../modules/lambda"

  name_prefix = var.name_prefix

  firebase_credentials_secret_name = var.firebase_credentials_secret_name
  compute_subnet_id                = module.network.compute_subnet_id
  lambda_sg_id                     = module.network.lambda_sg_id

  notification_events_queue_arn = module.data.notification_events_queue_arn
  lambda_sqs_consume_policy_arn = module.data.lambda_sqs_consume_policy_arn
  rds_secret_read_policy_arn    = module.data.rds_secret_read_policy_arn
}
