variable "region" {
  description = ""
  default = "us-east-1"
}
variable "lambda-name" {
  default = "order-lambda"
}
variable "lambda-handler" {
  default = "orderApi"
}
variable "lambda-filename" {
  default = "dist/orderApi.zip"
}

variable "orders-table-name" {
  default = "orders"
}

variable "workflow-name" {
  default = "order-workflow"
}