resource "aws_sqs_queue" "meter_events_dlq" {
  name                      = "asu-${var.environment}-meter-events-dlq"
  message_retention_seconds = 86400
  kms_master_key_id         = var.kms_key_arn

  tags = var.tags
}

resource "aws_sqs_queue" "meter_events" {
  name                       = "asu-${var.environment}-meter-events"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 86400
  kms_master_key_id          = var.kms_key_arn

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.meter_events_dlq.arn
    maxReceiveCount     = 3
  })

  tags = var.tags
}

resource "aws_sqs_queue_policy" "meter_events_policy" {
  queue_url = aws_sqs_queue.meter_events.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowIoTCoreSendMessage"
        Effect = "Allow"
        Principal = {
          Service = "iot.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.meter_events.arn
      }
    ]
  })
}

resource "aws_sns_topic" "alerts" {
  name              = "asu-${var.environment}-alerts"
  kms_master_key_id = var.kms_key_arn

  tags = var.tags
}

resource "aws_sns_topic_policy" "alerts_policy" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaPublish"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
