resource "aws_appautoscaling_target" "portal" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.portal.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "portal_cpu" {
  name               = "asu-${var.environment}-portal-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.portal.resource_id
  scalable_dimension = aws_appautoscaling_target.portal.scalable_dimension
  service_namespace  = aws_appautoscaling_target.portal.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 60.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "smdp" {
  max_capacity       = 6
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.smdp.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "smdp_cpu" {
  name               = "asu-${var.environment}-smdp-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.smdp.resource_id
  scalable_dimension = aws_appautoscaling_target.smdp.scalable_dimension
  service_namespace  = aws_appautoscaling_target.smdp.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 60.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 30
  }
}

resource "aws_appautoscaling_policy" "smdp_memory" {
  name               = "asu-${var.environment}-smdp-memory-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.smdp.resource_id
  scalable_dimension = aws_appautoscaling_target.smdp.scalable_dimension
  service_namespace  = aws_appautoscaling_target.smdp.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

output "portal_scaling_policy_arn" {
  description = "ARN of the portal scaling policy"
  value       = aws_appautoscaling_policy.portal_cpu.arn
}

output "smdp_scaling_policy_arn" {
  description = "ARN of the smdp CPU scaling policy"
  value       = aws_appautoscaling_policy.smdp_cpu.arn
}
