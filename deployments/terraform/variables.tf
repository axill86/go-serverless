variable "region" {
  description = ""
  default = "us-east-1"
}
//Order lambda
variable "order-lambda-name" {
  default = "order-lambda"
}
variable "order-lambda-handler" {
  default = "orderApi"
}
variable "order-lambda-filename" {
  default = "dist/orderApi.zip"
}

variable "orders-table-name" {
  default = "orders"
}
//Configurations Lambda
variable "configurations-lambda-name" {
  default = "generate-configurations-lambda"
}
variable "configurations-lambda-handler" {
  default = "generateConfigurations"
}
variable "configurations-lambda-filename" {
  default = "dist/generateConfigurations.zip"
}

//
variable "workflow-name" {
  default = "order-workflow"
}