output "lambda-invoke-arn" {
  value = aws_lambda_function.order_lambda.invoke_arn
}

output "lamda-arn" {
  value = aws_lambda_function.order_lambda.arn
}

output "lambda-function-name" {
  value = aws_lambda_function.order_lambda.function_name
}