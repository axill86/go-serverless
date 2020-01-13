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
module "order-lambda" {
  source = "./order-lambda"
  lambda-name = var.lambda-name
  lambda-filename = var.lambda-filename
  lambda-handler = var.lambda-handler
  table-name = module.order-table.table-arn
}

module "order-api" {
  source = "./order-api"
  lambda-invoke-arn = module.order-lambda.lambda-invoke-arn
  handler-function-name = module.order-lambda.lambda-function-name
}

