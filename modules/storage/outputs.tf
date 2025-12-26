output "documents_bucket_name" {
  value = aws_s3_bucket.documents.bucket
}

output "lambda_artifacts_bucket_name" {
  value = aws_s3_bucket.lambda_artifacts.bucket
}

output "metadata_table_name" {
  value = aws_dynamodb_table.metadata.name
}
