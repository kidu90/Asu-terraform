resource "aws_dynamodb_table" "meter_telemetry" {
  name         = "asu-dev-meter-telemetry"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "meter_id"
  range_key = "timestamp"

  attribute {
    name = "meter_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.dynamodb_kms_key_arn
  }

  ttl {
    attribute_name = "expiry_time"
    enabled        = true
  }

  global_secondary_index {
    name            = "status-index"
    hash_key        = "status"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = var.tags
}
