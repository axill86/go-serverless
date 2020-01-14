provider "aws" {
  region = var.region
}

module "order-table" {
  source = "./order-table"
  orders-table-name = var.orders-table-name
}
module "order-workflow" {
  source = "./order-workflow"
  workflow-name = var.workflow-name
}
#Inline Policy for order-lambda
data aws_iam_policy_document "order-lambda-policy" {
  statement {
    actions = ["dynamodb:DeleteItem", "dynamodb:DescribeTable", "dynamodb:PutItem", "dynamodb:GetItem"]
    resources = [module.order-table.table-arn]
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

module "order-lambda" {
  source = "./lambda"
  lambda-name = var.order-lambda-name
  lambda-filename = var.order-lambda-filename
  lambda-handler = var.order-lambda-handler
  policy-document = data.aws_iam_policy_document.order-lambda-policy.json
}

data aws_iam_policy_document "configurations-lambda-policy" {
  statement {
    actions = ["logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
    effect = "Allow"
  }
}

module "configurations-lambda" {
  source = "./lambda"
  lambda-name = var.configurations-lambda-name
  lambda-filename =  var.configurations-lambda-filename
  lambda-handler = var.configurations-lambda-handler
  policy-document = data.aws_iam_policy_document.configurations-lambda-policy.json
}

module "order-api" {
  source = "./order-api"
  lambda-invoke-arn = module.order-lambda.lambda-invoke-arn
  handler-function-name = module.order-lambda.lambda-function-name
}

