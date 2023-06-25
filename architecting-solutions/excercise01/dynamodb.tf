resource "aws_dynamodb_table" "orders" {
  name           = "orders"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "orderID"
  attribute {
    name = "orderID"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
}
