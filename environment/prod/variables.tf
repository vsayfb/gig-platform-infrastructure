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
  description = "Admin IP allowed to SSH into the NAT instance, as a /32."
  type        = string
}

variable "db_name" {
  description = "Initial database name created on the instance."
  type        = string
}

variable "mongo_db_name" {
  description = "Name of the database in Mongo."
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

variable "app_port_range" {
  description = "Core's port (from) and Chat's port (to) - the range the ALB is allowed to reach on private_services_sg, and what compute/'s target groups listen on."
  type = object({
    from = number
    to   = number
  })
  default = {
    from = 8080
    to   = 8081
  }
}

variable "grafana_cloud_opamp_endpoint" {
  description = "Grafana Cloud Fleet Management OpAMP endpoint."
  type        = string
}

variable "grafana_cloud_opamp_auth_token_parameter_name" {
  description = "Name of the SSM SecureString parameter holding the OpAMP Authorization header value."
  type        = string
}

variable "grafana_cloud_otlp_write_key_parameter_name" {
  description = "Name of the SSM SecureString parameter holding the value of write key."
  type        = string
}

variable "firebase_credentials_secret_name" {
  description = "Identity/User of the secret"
  type        = string
}

variable "github_org" {
  description = "GitHub org/user that owns the app repos allowed to assume the deploy role."
  type        = string
}

variable "github_repos" {
  description = "Repo names (without org prefix) whose workflows can assume the deploy role."
  type        = list(string)
}

# Runtime config

variable "google_client_id" {
  description = "OAuth client ID for Google Sign-In. Not secret."
  type        = string
}

variable "jwt_secret_name" {
  description = "Name of the Secrets Manager secret holding the shared JWT signing secret."
  type        = string
}

variable "mongo_db_uri_secret_name" {
  description = "Name of the Secrets Manager secret holding the MongoDB Atlas connection URI"
  type        = string
}
