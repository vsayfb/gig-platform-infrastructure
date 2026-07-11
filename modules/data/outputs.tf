output "compute_az" {
  description = "AZ where application actually run."
  value       = var.compute_az
}

output "rds_endpoint" {
  description = "Connection endpoint (host:port), for DATABASE_URL construction."
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "Host only, no port."
  value       = aws_db_instance.main.address
}

output "rds_port" {
  value = aws_db_instance.main.port
}

output "rds_db_name" {
  value = aws_db_instance.main.db_name
}

output "rds_master_username" {
  description = "Auto-generated master username."
  value       = local.db_master_username
}

output "rds_master_user_secret_arn" {
  description = "Secrets Manager ARN holding the AWS-generated master password."
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}

output "category_events_queue_url" {
  value = aws_sqs_queue.category_events.url
}

output "category_events_queue_arn" {
  value = aws_sqs_queue.category_events.arn
}

output "notification_events_queue_url" {
  value = aws_sqs_queue.notification_events.url
}

output "notification_events_queue_arn" {
  value = aws_sqs_queue.notification_events.arn
}

output "core_sqs_produce_policy_arn" {
  value = aws_iam_policy.core_sqs_produce.arn
}

output "worker_sqs_access_policy_arn" {
  value = aws_iam_policy.worker_sqs_access.arn
}

output "lambda_sqs_consume_policy_arn" {
  value = aws_iam_policy.lambda_sqs_consume.arn
}
