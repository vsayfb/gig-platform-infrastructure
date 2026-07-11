output "vpc_id" {
  value = module.network.vpc_id
}

output "nat_instance_public_ip" {
  description = "SSH here to jump into the private subnet."
  value       = module.network.nat_instance_public_ip
}
