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

resource "aws_instance" "core_chat" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.core_chat_instance_type
  subnet_id              = var.compute_subnet_id
  vpc_security_group_ids = [var.private_services_sg_id]
  key_name               = var.ssh_key_name
  iam_instance_profile   = aws_iam_instance_profile.core_chat.name

  user_data = file("${path.module}/scripts/bootstrap.sh")

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-core-chat" })
}

resource "aws_instance" "worker" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.worker_instance_type
  subnet_id              = var.compute_subnet_id
  vpc_security_group_ids = [var.private_services_sg_id]
  key_name               = var.ssh_key_name
  iam_instance_profile   = aws_iam_instance_profile.worker.name

  user_data = file("${path.module}/scripts/bootstrap.sh")

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-worker" })
}
