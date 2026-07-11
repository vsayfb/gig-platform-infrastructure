resource "aws_iam_policy" "core_sqs_produce" {
  name        = "${local.name_prefix}-core-sqs-produce"
  description = "Core: send-only access to gig-category-events"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = aws_sqs_queue.category_events.arn
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_policy" "worker_sqs_access" {
  name        = "${local.name_prefix}-worker-sqs-access"
  description = "Categorization Worker: consume gig-category-events, produce gig-notification-events"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
        ]
        Resource = aws_sqs_queue.category_events.arn
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = aws_sqs_queue.notification_events.arn
      }
    ]
  })

  tags = local.common_tags
}

