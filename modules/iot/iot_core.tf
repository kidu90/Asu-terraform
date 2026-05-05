resource "aws_iot_thing_type" "smart_meter" {
  name = "SmartMeter"

  properties {
    description = "ASU smart water/energy meters"
  }
}

resource "aws_iot_policy" "meter_policy" {
  name = "asu-${var.environment}-meter-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iot:Connect",
          "iot:Publish",
          "iot:Subscribe",
          "iot:Receive"
        ]
        Resource = "arn:aws:iot:*:*:*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "iot_errors" {
  name              = "asu-${var.environment}-iot-errors"
  retention_in_days = 14
  tags              = var.tags
}

resource "aws_iot_topic_rule" "meter_ingest" {
  name        = "asu_dev_meter_ingest"
  description = "Ingest meter telemetry from MQTT topic"
  enabled     = true
  sql         = "SELECT * FROM 'meters/+/telemetry'"
  sql_version = "2016-03-23"

  sqs {
    role_arn   = var.iot_role_arn
    queue_url  = aws_sqs_queue.meter_events.id
    use_base64 = false
  }

  s3 {
    role_arn    = var.iot_role_arn
    bucket_name = var.raw_telemetry_bucket
    key         = "$${topic()}/$${timestamp()}.json"
    canned_acl  = "private"
  }

  error_action {
    cloudwatch_logs {
      role_arn       = var.iot_role_arn
      log_group_name = aws_cloudwatch_log_group.iot_errors.name
    }
  }
}
