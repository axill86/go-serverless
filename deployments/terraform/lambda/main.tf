locals {
  environment_map = var.environment-variables == null ? [] : [var.environment-variables]
}

resource "aws_lambda_function" "order_lambda" {
  function_name = var.lambda-name
  handler = var.lambda-handler
  role = aws_iam_role.lambda_exec.arn
  runtime = "go1.x"
  filename = var.lambda-filename
  source_code_hash = filebase64sha256(var.lambda-filename)

  dynamic environment {
    for_each = local.environment_map
    content {
      variables = environment.value
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda-name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy" "lambda_inline_policy" {
  policy = var.policy-document
  role = aws_iam_role.lambda_exec.name
  name = "${var.lambda-name}-policy"
}

#Attaching basic execution Policy
resource "aws_iam_role_policy_attachment" "lambda-logs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.lambda_exec.name
}





data "aws_iam_policy_document" "lambda_policy" {
  #Allows Lambda to assume execution Role
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
    effect = "Allow"
  }
}