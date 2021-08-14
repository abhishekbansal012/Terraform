resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "tf_lock_pixlaunch"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    env = "DEV"
  }
}
