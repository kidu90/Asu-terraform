output "glue_database_name" {
  description = "Name of the Glue catalog database for telemetry"
  value       = aws_glue_catalog_database.telemetry_db.name
}

output "crawler_name" {
  description = "Name of the Glue crawler for telemetry raw data"
  value       = aws_glue_crawler.telemetry_crawler.name
}

output "etl_job_name" {
  description = "Name of the Glue ETL job for JSON to Parquet conversion"
  value       = aws_glue_job.json_to_parquet.name
}

output "athena_workgroup_name" {
  description = "Name of the Athena workgroup for telemetry queries"
  value       = aws_athena_workgroup.telemetry_workgroup.name
}

output "glue_role_arn" {
  description = "ARN of the Glue IAM role"
  value       = aws_iam_role.glue_role.arn
}

output "notebook_instance_name" {
  description = "Name of the SageMaker notebook instance for forecasting"
  value       = aws_sagemaker_notebook_instance.forecasting_notebook.name
}

output "notebook_instance_url" {
  description = "URL of the SageMaker notebook instance"
  value       = aws_sagemaker_notebook_instance.forecasting_notebook.url
}
