resource "aws_iam_policy" "observability_read" {
  name        = "${local.name_prefix}-observability-read"
  description = "Read-only access to the Grafana Cloud OpAMP endpoint + auth token SSM parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["ssm:GetParameter"]
        Resource = [
          aws_ssm_parameter.opamp_endpoint.arn,
          data.aws_ssm_parameter.opamp_auth_token.arn,
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "core_chat_observability_read" {
  role       = var.core_chat_role_name
  policy_arn = aws_iam_policy.observability_read.arn
}

resource "aws_iam_role_policy_attachment" "worker_observability_read" {
  role       = var.worker_role_name
  policy_arn = aws_iam_policy.observability_read.arn
}
