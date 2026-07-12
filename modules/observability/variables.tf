variable "name_prefix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "grafana_cloud_opamp_endpoint" {
  description = "Grafana Cloud Fleet Management OpAMP endpoint."
  type        = string
}

variable "grafana_cloud_opamp_auth_token_parameter_name" {
  description = "Name of the SSM SecureString parameter holding the OpAMP Authorization header value."
  type        = string
}

# IAM Roles from Compute Module

variable "core_chat_role_name" {
  description = "Name of the core chat IAM role."
  type        = string
}

variable "worker_role_name" {
  description = "Name of the worker IAM role."
  type        = string
}


