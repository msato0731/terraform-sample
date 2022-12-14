resource "aws_dynamodb_table" "this" {
  hash_key     = "partition_key"
  range_key    = "sort_key"
  attribute {
    name = "partition_key"
    type = "S"
  }
  attribute {
    name = "sort_key"
    type = "S"
  }
}