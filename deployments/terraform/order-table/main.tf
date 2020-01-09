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