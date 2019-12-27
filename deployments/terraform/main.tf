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