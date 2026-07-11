output "vpc_id" {
  value = module.network.vpc_id
}

output "nat_instance_public_ip" {
  description = "SSH here to jump into the private subnet."
  value       = module.network.nat_instance_public_ip
}

output "rds_endpoint" {
  value = module.data.rds_endpoint
}

output "rds_master_user_secret_arn" {
  value = module.data.rds_master_user_secret_arn
}

output "rds_db_name" {
  value = module.data.rds_db_name
}

output "compute_az" {
  value = module.data.compute_az
}
