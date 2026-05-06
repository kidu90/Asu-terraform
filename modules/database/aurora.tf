resource "aws_db_subnet_group" "aurora" {
  name       = "asu-${var.environment}-db-subnet-group"
  subnet_ids = var.private_data_subnet_ids
  tags       = var.tags
}

resource "aws_rds_cluster_parameter_group" "aurora_params" {
  name        = "asu-${var.environment}-aurora-params"
  family      = "aurora-postgresql15"
  description = "AquaSense Aurora PostgreSQL cluster parameters"
  tags        = var.tags

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier              = "asu-${var.environment}-aurora-cluster"
  availability_zones              = var.availability_zones
  engine                          = "aurora-postgresql"
  engine_version                  = "15.4"
  database_name                   = "aquasense"
  master_username                 = "asuperadmin"
  master_password                 = var.db_password
  db_subnet_group_name            = aws_db_subnet_group.aurora.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_params.name
  vpc_security_group_ids          = [var.db_sg_id]
  backup_retention_period         = 7
  preferred_backup_window         = "02:00-03:00"
  storage_encrypted               = true
  kms_key_id                      = var.kms_key_arn
  skip_final_snapshot             = true
  apply_immediately               = true
  enabled_cloudwatch_logs_exports = ["postgresql"]
  deletion_protection             = false

  tags = var.tags
}

resource "aws_rds_cluster_instance" "writer" {
  cluster_identifier           = aws_rds_cluster.aurora.id
  identifier                   = "asu-${var.environment}-aurora-writer"
  instance_class               = "db.t3.medium"
  engine                       = aws_rds_cluster.aurora.engine
  engine_version               = aws_rds_cluster.aurora.engine_version
  publicly_accessible          = false
  performance_insights_enabled = false
  monitoring_interval          = 0

  tags = var.tags
}

resource "aws_rds_cluster_instance" "reader" {
  cluster_identifier           = aws_rds_cluster.aurora.id
  identifier                   = "asu-${var.environment}-aurora-reader"
  instance_class               = "db.t3.medium"
  engine                       = aws_rds_cluster.aurora.engine
  engine_version               = aws_rds_cluster.aurora.engine_version
  publicly_accessible          = false
  performance_insights_enabled = false
  monitoring_interval          = 0
  promotion_tier               = 1

  tags = var.tags
}
