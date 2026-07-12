data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  bootstrap_vars_base = {
    aws_region                       = var.aws_region
    opamp_endpoint_parameter_name    = var.opamp_endpoint_parameter_name
    opamp_auth_token_parameter_name  = var.opamp_auth_token_parameter_name
    otel_collector_version           = var.otel_collector_version
    opamp_supervisor_version         = var.opamp_supervisor_version
  }
}

resource "aws_instance" "core_chat" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.core_chat_instance_type
  subnet_id              = var.compute_subnet_id
  vpc_security_group_ids = [var.private_services_sg_id]
  key_name               = var.ssh_key_name
  iam_instance_profile   = aws_iam_instance_profile.core_chat.name

  user_data = templatefile("${path.module}/scripts/bootstrap.sh.tpl", merge(
    local.bootstrap_vars_base,
    { service_name = "core-chat" }
  ))

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-core-chat" })
}

resource "aws_instance" "worker" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.worker_instance_type
  subnet_id              = var.compute_subnet_id
  vpc_security_group_ids = [var.private_services_sg_id]
  key_name               = var.ssh_key_name
  iam_instance_profile   = aws_iam_instance_profile.worker.name

  user_data = templatefile("${path.module}/scripts/bootstrap.sh.tpl", merge(
    local.bootstrap_vars_base,
    { service_name = "worker" }
  ))

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-worker" })
}
