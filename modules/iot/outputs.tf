output "sqs_queue_url" {
  description = "URL of the SQS meter events queue"
  value       = aws_sqs_queue.meter_events.id
}

output "sqs_queue_arn" {
  description = "ARN of the SQS meter events queue"
  value       = aws_sqs_queue.meter_events.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS alerts topic"
  value       = aws_sns_topic.alerts.arn
}

output "dlq_arn" {
  description = "ARN of the SQS dead-letter queue"
  value       = aws_sqs_queue.meter_events_dlq.arn
}
