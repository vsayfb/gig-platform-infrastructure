variable "name_prefix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "core_chat_instance_name_tag" {
  type    = string
  default = null
}

variable "worker_instance_name_tag" {
  type    = string
  default = null
}

# GitHub Actions OIDC

variable "github_org" {
  description = "GitHub org/user that owns the app repos allowed to assume the deploy role."
  type        = string
}

variable "github_repos" {
  description = "Repo names (without org prefix) whose workflows can assume the deploy role."
  type        = list(string)
}
