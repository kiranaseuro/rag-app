resource "aws_cognito_user_pool" "this" {
  name = "${var.project_name}-${var.environment}-user-pool"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-user-pool"
  })
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.project_name}-${var.environment}-user-pool-client"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret     = false
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}
