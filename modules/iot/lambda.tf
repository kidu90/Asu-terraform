terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

data "archive_file" "meter_processor_zip" {
  type = "zip"

  source {
    filename = "index.py"
    content  = <<-EOT
import json
import logging
import os
from datetime import datetime, timezone

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["DYNAMODB_TABLE"])


def handler(event, context):
    records = event.get("Records", [])

    for record in records:
        body = record.get("body", "{}")

        try:
            meter_data = json.loads(body)
        except json.JSONDecodeError:
            logger.exception("Invalid JSON in SQS body: %s", body)
            continue

        meter_id = str(meter_data.get("meter_id", "unknown"))
        timestamp = str(meter_data.get("timestamp", datetime.now(timezone.utc).isoformat()))

        item = {
            "meter_id": meter_id,
            "timestamp": timestamp,
            "status": "processed",
        }

        table.put_item(Item=item)
        logger.info("Processed record for meter_id=%s timestamp=%s", meter_id, timestamp)

    return {"statusCode": 200, "processed": len(records)}
EOT
  }

  output_path = "${path.module}/meter_processor.zip"
}

resource "aws_lambda_function" "meter_processor" {
  function_name = "asu-${var.environment}-meter-processor"
  role          = var.lambda_role_arn
  runtime       = "python3.12"
  handler       = "index.handler"
  timeout       = 60
  memory_size   = 256
  filename      = data.archive_file.meter_processor_zip.output_path

  source_code_hash = data.archive_file.meter_processor_zip.output_base64sha256
  kms_key_arn      = var.kms_key_arn

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
      SNS_TOPIC_ARN  = var.sns_topic_arn
      ENVIRONMENT    = var.environment
    }
  }

  vpc_config {
    subnet_ids         = var.private_app_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }

  tags = var.tags
}

resource "aws_lambda_event_source_mapping" "meter_events_to_processor" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.meter_processor.arn
  batch_size       = 10
  enabled          = true
}

data "archive_file" "anomaly_detector_zip" {
  type = "zip"

  source {
    filename = "index.py"
    content  = <<-EOT
import json
import logging
import os

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

sns = boto3.client("sns")
THRESHOLD = 500


def handler(event, context):
    meter_id = event.get("meter_id", "unknown")
    reading = float(event.get("reading", 0))

    if reading > THRESHOLD:
        message = {
            "meter_id": meter_id,
            "reading": reading,
            "threshold": THRESHOLD,
            "alert": "Anomalous reading detected",
        }
        sns.publish(
            TopicArn=os.environ["SNS_TOPIC_ARN"],
            Subject="AquaSense Meter Anomaly",
            Message=json.dumps(message),
        )
        logger.info("Published anomaly alert for meter_id=%s reading=%s", meter_id, reading)
    else:
        logger.info("No anomaly detected for meter_id=%s reading=%s", meter_id, reading)

    return {"statusCode": 200}
EOT
  }

  output_path = "${path.module}/anomaly_detector.zip"
}

resource "aws_lambda_function" "anomaly_detector" {
  function_name = "asu-${var.environment}-anomaly-detector"
  role          = var.lambda_role_arn
  runtime       = "python3.12"
  handler       = "index.handler"
  timeout       = 30
  memory_size   = 128
  filename      = data.archive_file.anomaly_detector_zip.output_path

  source_code_hash = data.archive_file.anomaly_detector_zip.output_base64sha256
  kms_key_arn      = var.kms_key_arn

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "anomaly_schedule" {
  name                = "asu-${var.environment}-anomaly-detector-schedule"
  description         = "Trigger anomaly detector every 5 minutes"
  schedule_expression = "rate(5 minutes)"
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "anomaly_lambda_target" {
  rule      = aws_cloudwatch_event_rule.anomaly_schedule.name
  target_id = "anomaly-detector-lambda"
  arn       = aws_lambda_function.anomaly_detector.arn
}

resource "aws_lambda_permission" "allow_eventbridge_invoke_anomaly" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.anomaly_detector.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.anomaly_schedule.arn
}
