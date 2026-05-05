data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  dashboard_name            = "ASU-Operations"
  cloudtrail_log_group_name = "/asu/cloudtrail"
  lambda_processor_name     = "asu-${var.environment}-meter-processor"
  lambda_anomaly_name       = "asu-${var.environment}-anomaly-detector"
  sqs_queue_name            = element(split(":", var.sqs_queue_arn), 5)
  sns_topic_name            = element(split(":", var.sns_topic_arn), 5)
}

resource "aws_cloudwatch_log_group" "ecs_portal" {
  name              = "/asu/ecs/portal"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "ecs_smdp" {
  name              = "/asu/ecs/smdp"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "lambda_processor" {
  name              = "/asu/lambda/processor"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "lambda_anomaly" {
  name              = "/asu/lambda/anomaly"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "iot_errors" {
  name              = "/asu/iot/errors"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = local.cloudtrail_log_group_name
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_iam_role" "cloudtrail_logs" {
  name = "asu-${var.environment}-cloudtrail-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "cloudtrail_logs" {
  name = "asu-${var.environment}-cloudtrail-logs-policy"
  role = aws_iam_role.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      }
    ]
  })
}

resource "aws_cloudtrail" "trail" {
  name                          = "asu-${var.environment}-trail"
  s3_bucket_name                = var.cloudtrail_bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_key_arn
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail.arn
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_logs.arn

  tags = var.tags

  depends_on = [aws_iam_role_policy.cloudtrail_logs]
}

resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}

resource "aws_cloudwatch_dashboard" "operations" {
  dashboard_name = local.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Invocations and Errors"
          region = data.aws_region.current.name
          stat   = "Sum"
          period = 300
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", local.lambda_processor_name],
            [".", "Errors", ".", "."],
            [".", "Invocations", "FunctionName", local.lambda_anomaly_name],
            [".", "Errors", ".", "."]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "DynamoDB Consumed Capacity"
          region = data.aws_region.current.name
          stat   = "Sum"
          period = 300
          metrics = [
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", var.dynamodb_table_name],
            [".", "ConsumedWriteCapacityUnits", ".", "."]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "SQS Messages Sent and Received"
          region = data.aws_region.current.name
          stat   = "Sum"
          period = 300
          metrics = [
            ["AWS/SQS", "NumberOfMessagesSent", "QueueName", local.sqs_queue_name],
            [".", "NumberOfMessagesReceived", ".", "."]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "SNS Number of Notifications"
          region = data.aws_region.current.name
          stat   = "Sum"
          period = 300
          metrics = [
            ["AWS/SNS", "NumberOfNotificationsDelivered", "TopicName", local.sns_topic_name]
          ]
          view = "timeSeries"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "asu-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 5
  period              = 300
  statistic           = "Sum"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  dimensions = {
    FunctionName = local.lambda_processor_name
  }
  alarm_description = "Alarm when Lambda errors exceed 5 in 5 minutes"
  alarm_actions     = [var.sns_topic_arn]
  ok_actions        = [var.sns_topic_arn]
  tags              = var.tags
}

resource "aws_cloudwatch_metric_alarm" "sqs_depth" {
  alarm_name          = "asu-sqs-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 100
  period              = 300
  statistic           = "Maximum"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  dimensions = {
    QueueName = local.sqs_queue_name
  }
  alarm_description = "Alarm when SQS depth exceeds 100 visible messages"
  alarm_actions     = [var.sns_topic_arn]
  ok_actions        = [var.sns_topic_arn]
  tags              = var.tags
}
