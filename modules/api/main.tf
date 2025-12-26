resource "aws_apigatewayv2_api" "this" {
  name          = "${var.project_name}-${var.environment}-http-api"
  protocol_type = "HTTP"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-http-api"
  })
}

resource "aws_apigatewayv2_integration" "lambda" {
  for_each = var.routes

  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_invoke_arns[each.value.lambda_key]
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "this" {
  for_each = var.routes

  api_id    = aws_apigatewayv2_api.this.id
  route_key = "${each.value.method} ${each.value.path}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda[each.key].id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.environment
  auto_deploy = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-http-stage"
  })
}

resource "aws_lambda_permission" "api" {
  for_each = var.routes

  statement_id  = "AllowExecutionFromApiGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names[each.value.lambda_key]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
