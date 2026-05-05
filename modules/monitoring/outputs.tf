output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.operations.dashboard_name
}

output "trail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.trail.arn
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = aws_guardduty_detector.this.id
}
