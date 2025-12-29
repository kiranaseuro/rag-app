variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "initial_secrets" {
  type      = map(string)
  default   = {}
  sensitive = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_secretsmanager_secret" "this" {
  name = "${var.project_name}/${var.environment}/app-secrets"
  recovery_window_in_days = 0 # For dev convenience, use 7+ for prod
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(var.initial_secrets)
}

output "secret_arn" {
  value = aws_secretsmanager_secret.this.arn
}

output "secret_name" {
  value = aws_secretsmanager_secret.this.name
}
