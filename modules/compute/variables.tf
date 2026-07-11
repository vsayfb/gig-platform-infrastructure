variable "name_prefix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Networking inputs, from the network module
variable "vpc_id" {
  type = string
}

variable "alb_subnet_ids" {
  description = "Public subnet IDs (2 AZs) for the ALB."
  type        = list(string)
}

variable "alb_sg_id" {
  type = string
}

#Instances
variable "core_port" {
  description = "Port Core's HTTP server listens on."
  type        = number
  default     = 8080
}

variable "chat_port" {
  description = "Port Chat's WebSocket server listens on."
  type        = number
  default     = 8081
}

# ALB

variable "core_path_pattern" {
  description = "ALB listener rule path pattern routed to Core's target group."
  type        = list(string)
  default     = ["/core/*"]
}

variable "chat_path_pattern" {
  description = "ALB listener rule path pattern routed to Chat's target group."
  type        = list(string)
  default     = ["/chat/*"]
}

variable "alb_idle_timeout" {
  description = "Must be raised well above the 60s default or idle WebSocket connections get dropped."
  type        = number
  default     = 3600
}

variable "health_check_path" {
  description = "Shared health-check path for both target groups."
  type        = string
  default     = "/health"
}
