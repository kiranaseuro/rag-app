resource "aws_ecr_repository" "this" {
  name                 = "${var.project_name}-${var.environment}-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}
