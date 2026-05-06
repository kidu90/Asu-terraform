output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "portal_tg_arn" {
  description = "ARN of the portal target group"
  value       = aws_lb_target_group.portal_tg.arn
}

output "smdp_tg_arn" {
  description = "ARN of the smdp target group"
  value       = aws_lb_target_group.smdp_tg.arn
}

output "alb_listener_arn" {
  description = "ARN of the ALB listener"
  value       = aws_lb_listener.http.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "portal_service_name" {
  description = "Name of the portal ECS service"
  value       = aws_ecs_service.portal.name
}

output "smdp_service_name" {
  description = "Name of the smdp ECS service"
  value       = aws_ecs_service.smdp.name
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.portal.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.portal.id
}
