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
