#Api GW for lambda
resource "aws_api_gateway_rest_api" "order_api" {
  name = "order_api"
}

resource "aws_api_gateway_resource" "orders_resource" {
  parent_id = aws_api_gateway_rest_api.order_api.root_resource_id
  path_part = "orders"
  rest_api_id = aws_api_gateway_rest_api.order_api.id
}

resource "aws_api_gateway_method" "get_order" {
  authorization = "NONE"
  http_method = "ANY"
  resource_id = aws_api_gateway_resource.orders_resource.id
  rest_api_id = aws_api_gateway_rest_api.order_api.id
}

resource "aws_api_gateway_integration" "get_order" {
  http_method = aws_api_gateway_method.get_order.http_method
  resource_id = aws_api_gateway_resource.orders_resource.id
  rest_api_id = aws_api_gateway_rest_api.order_api.id
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = var.lambda-invoke-arn
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.handler-function-name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.order_api.execution_arn}/*/*/*"
}

resource "aws_api_gateway_deployment" "order_test_deployment" {
  depends_on = [
    aws_api_gateway_integration.get_order,
  ]

  rest_api_id = aws_api_gateway_rest_api.order_api.id
  stage_name  = "test"
}