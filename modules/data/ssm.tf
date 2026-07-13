resource "aws_ssm_parameter" "db_host" {
  name  = "/${local.name_prefix}/app/db-host"
  type  = "String"
  value = aws_db_instance.main.address

  tags = local.common_tags
}

resource "aws_ssm_parameter" "db_port" {
  name  = "/${local.name_prefix}/app/db-port"
  type  = "String"
  value = tostring(aws_db_instance.main.port)

  tags = local.common_tags
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/${local.name_prefix}/app/db-name"
  type  = "String"
  value = aws_db_instance.main.db_name

  tags = local.common_tags
}

resource "aws_ssm_parameter" "google_client_id" {
  name  = "/${local.name_prefix}/app/google-client-id"
  type  = "String"
  value = var.google_client_id

  tags = local.common_tags
}

resource "aws_ssm_parameter" "sqs_category_events_queue_url" {
  name  = "/${local.name_prefix}/app/sqs-category-events-queue-url"
  type  = "String"
  value = aws_sqs_queue.category_events.url

  tags = local.common_tags
}

data "aws_secretsmanager_secret" "jwt_secret" {
  name = var.jwt_secret_name
}

resource "aws_iam_policy" "app_config_read" {
  name        = "${local.name_prefix}-app-config-read"
  description = "Read-only access to plain app runtime config in SSM Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["ssm:GetParameter", "ssm:GetParameters"]
        Resource = [
          aws_ssm_parameter.db_host.arn,
          aws_ssm_parameter.db_port.arn,
          aws_ssm_parameter.db_name.arn,
          aws_ssm_parameter.google_client_id.arn,
          aws_ssm_parameter.sqs_category_events_queue_url.arn,
        ]
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_policy" "jwt_secret_read" {
  name        = "${local.name_prefix}-jwt-secret-read"
  description = "Read-only access to the shared JWT signing secret"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = data.aws_secretsmanager_secret.jwt_secret.arn
      }
    ]
  })

  tags = local.common_tags
}
