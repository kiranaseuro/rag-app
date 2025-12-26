resource "aws_s3_bucket" "documents" {
  bucket        = "${var.project_name}-${var.environment}-documents"
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-documents"
  })
}

resource "aws_s3_bucket" "lambda_artifacts" {
  bucket        = "${var.project_name}-${var.environment}-lambda-artifacts"
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-lambda-artifacts"
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
