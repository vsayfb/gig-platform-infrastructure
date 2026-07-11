resource "aws_iam_role" "core_chat" {
  name = "${local.name_prefix}-core-chat-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "core_chat_sqs_produce" {
  role       = aws_iam_role.core_chat.name
  policy_arn = var.core_sqs_produce_policy_arn
}

resource "aws_iam_role_policy_attachment" "core_chat_rds_secret" {
  role       = aws_iam_role.core_chat.name
  policy_arn = var.rds_secret_read_policy_arn
}

resource "aws_iam_instance_profile" "core_chat" {
  name = "${local.name_prefix}-core-chat-profile"
  role = aws_iam_role.core_chat.name
}

resource "aws_iam_role" "worker" {
  name = "${local.name_prefix}-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "worker_sqs_access" {
  role       = aws_iam_role.worker.name
  policy_arn = var.worker_sqs_access_policy_arn
}

resource "aws_iam_role_policy_attachment" "worker_rds_secret" {
  role       = aws_iam_role.worker.name
  policy_arn = var.rds_secret_read_policy_arn
}

resource "aws_iam_instance_profile" "worker" {
  name = "${local.name_prefix}-worker-profile"
  role = aws_iam_role.worker.name
}
