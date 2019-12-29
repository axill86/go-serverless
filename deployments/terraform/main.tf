provider "aws" {
  region = var.region
}

resource "aws_lambda_function" "order_lambda" {
  function_name = var.lambda-name
  handler = var.lambda-handler
  role = aws_iam_role.lambda_exec.arn
  runtime = "go1.x"
  filename = var.lambda-filename
  source_code_hash = filebase64sha256(var.lambda-filename)
}

resource "aws_iam_role" "lambda_exec" {
  assume_role_policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "dynamo_db_policy_attachment" {
  policy_arn = aws_iam_policy.orders_lambda_policy.arn
  role = aws_iam_role.lambda_exec.name
}

resource "aws_dynamodb_table" "orders_table" {
  hash_key = "id"
  name = var.orders-table-name
  read_capacity = 2
  write_capacity = 2
  attribute {
    name = "id"
    type = "S"
  }
}


resource "aws_iam_policy" "orders_lambda_policy" {
  name = "orders-lambda-dynamodb-policy"
  policy = data.aws_iam_policy_document.order_lambda_policy_document.json
}
data aws_iam_policy_document "order_lambda_policy_document" {
  statement {
    actions = ["dynamodb:DeleteItem", "dynamodb:DescribeTable", "dynamodb:PutItem", "dynamodb:GetItem"]
    resources = [aws_dynamodb_table.orders_table.arn]
    effect = "Allow"
  }
  statement {
    actions = ["logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
    effect = "Allow"
  }
}



data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
    effect = "Allow"
  }
}


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
  uri = aws_lambda_function.order_lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.order_lambda.function_name
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
