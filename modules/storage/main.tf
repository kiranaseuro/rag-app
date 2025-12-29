resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "documents" {
  bucket        = "devops-agent-${var.project_name}-${var.environment}-docs-${random_id.bucket_suffix.hex}"
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name = "devops-agent-docs"
  })
}

resource "aws_s3_bucket" "lambda_artifacts" {
  bucket        = "devops-agent-${var.project_name}-${var.environment}-artifacts-${random_id.bucket_suffix.hex}"
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name = "devops-agent-artifacts"
  })
}

resource "aws_dynamodb_table" "metadata" {
  name         = "${var.project_name}-${var.environment}-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "document_id"

  attribute {
    name = "document_id"
    type = "S"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-metadata"
  })
}
