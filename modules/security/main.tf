# KMS key for general S3/encryption
resource "aws_kms_key" "general" {
  description         = "AquaSense general encryption key"
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_kms_alias" "general_alias" {
  name          = "alias/asu-dev-general-key"
  target_key_id = aws_kms_key.general.key_id
}

# KMS key for DynamoDB
resource "aws_kms_key" "dynamodb" {
  description         = "AquaSense DynamoDB encryption key"
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_kms_alias" "dynamodb_alias" {
  name          = "alias/asu-dev-dynamodb-key"
  target_key_id = aws_kms_key.dynamodb.key_id
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_role" {
  name = "${var.environment}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_inline_policy" {
  name = "${var.environment}-lambda-inline-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ],
        Resource = "*"
      }
    ]
  })

  depends_on = [aws_iam_role_policy_attachment.lambda_basic]
}

# IAM role for IoT Core
resource "aws_iam_role" "iot_role" {
  name = "${var.environment}-iot-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "iot.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "iot_inline_policy" {
  name = "${var.environment}-iot-inline-policy"
  role = aws_iam_role.iot_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = "*"
      }
    ]
  })
}

# Security Groups
resource "aws_security_group" "asu_alb_sg" {
  name        = "asu-alb-sg"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id
  tags        = var.tags

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "asu_app_sg" {
  name        = "asu-app-sg"
  description = "App Security Group"
  vpc_id      = var.vpc_id
  tags        = var.tags

  ingress {
    description     = "From ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.asu_alb_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "asu_db_sg" {
  name        = "asu-db-sg"
  description = "DB Security Group"
  vpc_id      = var.vpc_id
  tags        = var.tags

  ingress {
    description     = "From app servers"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.asu_app_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "asu_lambda_sg" {
  name        = "asu-lambda-sg"
  description = "Lambda Security Group"
  vpc_id      = var.vpc_id
  tags        = var.tags

  # No ingress rules (no inbound allowed)

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
