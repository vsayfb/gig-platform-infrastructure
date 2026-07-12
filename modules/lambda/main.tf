locals {
  name_prefix = var.name_prefix
  common_tags = merge(var.tags, {
    ManagedBy = "terraform"
    Module    = "lambda"
  })
}

data "aws_secretsmanager_secret" "firebase_credentials" {
  name = var.firebase_credentials_secret_name
}

resource "aws_s3_object" "lambda_bootstrap" {
  bucket = var.lambda_deployment_s3_bucket
  key    = var.lambda_deployment_s3_key

  source = "${path.module}/bootstrap/placeholder.zip"
  etag   = filemd5("${path.module}/bootstrap/placeholder.zip")
}

resource "aws_lambda_function" "notification" {
  function_name = "${local.name_prefix}-notification-lambda"

  s3_bucket = aws_s3_object.lambda_bootstrap.bucket
  s3_key    = aws_s3_object.lambda_bootstrap.key

  runtime = var.runtime
  handler = var.handler

  role        = aws_iam_role.lambda.arn
  memory_size = var.memory_size
  timeout     = var.timeout_seconds

  vpc_config {
    subnet_ids         = [var.compute_subnet_id]
    security_group_ids = [var.lambda_sg_id]
  }

  environment {
    variables = {
      FIREBASE_CREDENTIALS_SECRET_ARN = data.aws_secretsmanager_secret.firebase_credentials.arn
    }
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-notification-lambda" })

  lifecycle {
    ignore_changes = [s3_key, source_code_hash]
  }
}

resource "aws_lambda_event_source_mapping" "notification_events" {
  event_source_arn = var.notification_events_queue_arn
  function_name    = aws_lambda_function.notification.arn
  batch_size       = var.sqs_batch_size
  enabled          = true
}

