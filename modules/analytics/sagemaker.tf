# IAM Role for SageMaker
resource "aws_iam_role" "sagemaker_role" {
  name = "asu-${var.environment}-sagemaker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach AWS managed policy for SageMaker full access
resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# Inline policy for S3 and KMS access
resource "aws_iam_role_policy" "sagemaker_s3_kms_policy" {
  name = "asu-${var.environment}-sagemaker-s3-kms-policy"
  role = aws_iam_role.sagemaker_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.raw_telemetry_bucket_arn,
          "${var.raw_telemetry_bucket_arn}/*",
          var.processed_data_bucket_arn,
          "${var.processed_data_bucket_arn}/*"
        ]
      },
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}

# SageMaker Notebook Instance Lifecycle Configuration
resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "notebook_lifecycle" {
  name = "asu-${var.environment}-notebook-lifecycle"

  on_start = [base64encode(<<-EOT
    #!/bin/bash
    set -e
    
    # Update pip
    /home/ec2-user/anaconda3/envs/python3/bin/pip install --upgrade pip
    
    # Install required Python packages
    /home/ec2-user/anaconda3/envs/python3/bin/pip install \
      boto3 \
      pandas \
      matplotlib \
      scikit-learn \
      numpy \
      jupyter \
      jupyterlab
    
    echo "Notebook lifecycle configuration completed"
  EOT
  )]
}

# SageMaker Notebook Instance for forecasting
resource "aws_sagemaker_notebook_instance" "forecasting_notebook" {
  name                   = "asu-${var.environment}-forecasting"
  instance_type          = "ml.t3.medium"
  role_arn               = aws_iam_role.sagemaker_role.arn
  direct_internet_access = true
  root_access            = true
  lifecycle_config_name  = aws_sagemaker_notebook_instance_lifecycle_configuration.notebook_lifecycle.name

  tags = merge(
    var.tags,
    {
      Name = "asu-${var.environment}-forecasting-notebook"
    }
  )

  depends_on = [
    aws_sagemaker_notebook_instance_lifecycle_configuration.notebook_lifecycle,
    aws_iam_role_policy.sagemaker_s3_kms_policy
  ]
}
