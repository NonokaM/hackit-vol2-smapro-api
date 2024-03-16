resource "aws_dynamodb_table" "hackit_table" {
  name           = "hackit_questions_table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "N"
  }

  attribute {
    name = "difficulty"
    type = "S"
  }

  global_secondary_index {
    name            = "difficulty-index"
    hash_key        = "difficulty"
    range_key       = "id"
    read_capacity   = 5
    write_capacity  = 5
    projection_type = "ALL"
  }
}
