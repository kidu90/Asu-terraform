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

output "meter_processor_arn" {
  description = "ARN of the meter processor Lambda function"
  value       = aws_lambda_function.meter_processor.arn
}

output "anomaly_detector_arn" {
  description = "ARN of the anomaly detector Lambda function"
  value       = aws_lambda_function.anomaly_detector.arn
}

output "iot_thing_type_name" {
  description = "Name of the IoT thing type"
  value       = aws_iot_thing_type.smart_meter.name
}

output "iot_policy_name" {
  description = "Name of the IoT policy"
  value       = aws_iot_policy.meter_policy.name
}

output "iot_rule_name" {
  description = "Name of the IoT topic rule"
  value       = aws_iot_topic_rule.meter_ingest.name
}

output "kinesis_stream_name" {
  description = "Name of the Kinesis Data Stream for meter data"
  value       = aws_kinesis_stream.meter_stream.name
}

output "kinesis_stream_arn" {
  description = "ARN of the Kinesis Data Stream for meter data"
  value       = aws_kinesis_stream.meter_stream.arn
}

output "firehose_name" {
  description = "Name of the Kinesis Firehose delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.meter_to_s3.name
}
