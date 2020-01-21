output "table-arn" {
  value = aws_dynamodb_table.orders_table.arn
}

output "table-name" {
  value = aws_dynamodb_table.orders_table.name
}