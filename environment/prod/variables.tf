variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to every resource name/tag across all modules."
  type        = string
}

variable "azs" {
  description = "Two Availability Zones to spread subnets across. Index 0 carries real compute; index 1 exists only to satisfy ALB/RDS AZ-count requirements."
  type        = list(string)
}

variable "ssh_key_name" {
  description = "Existing EC2 key pair name, used for the NAT instance and (tunnelled through it) the private instances."
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Admin IP allowed to SSH into the NAT instance, as a /32. No default on purpose - must be set explicitly."
  type        = string
}

variable "db_name" {
  description = "Initial database name created on the instance."
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB."
  type        = number
  default     = 20
}

variable "db_backup_retention_days" {
  description = "Automated backup retention period, in days."
  type        = number
  default     = 1
}
