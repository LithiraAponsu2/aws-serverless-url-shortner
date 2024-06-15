resource "aws_dynamodb_table" "dynamodb_table" {
  name = "URLs"
  hash_key = "short_url"  # partition key

  read_capacity = 5 # used default values given by console, must be , 1<=x 
  write_capacity = 5

  attribute {
    name = "short_url"
    type = "S"  # string type partition key
  }
}


