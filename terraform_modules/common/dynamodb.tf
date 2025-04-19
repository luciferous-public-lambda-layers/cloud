# ================================================================
# DynamoDB Table layers
# ================================================================

resource "aws_dynamodb_table" "layers" {
  name             = "layers"
  hash_key         = "identifier"
  billing_mode     = "PAY_PER_REQUEST"
  table_class      = "STANDARD_INFREQUENT_ACCESS"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "identifier"
    type = "S"
  }
}

# ================================================================
# DynamoDB Table layers_dev
# ================================================================

resource "aws_dynamodb_table" "layers_dev" {
  name             = "layers_dev"
  hash_key         = "identifier"
  billing_mode     = "PAY_PER_REQUEST"
  table_class      = "STANDARD_INFREQUENT_ACCESS"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "identifier"
    type = "S"
  }
}

# ================================================================
# DynamoDB Table history
# ================================================================

resource "aws_dynamodb_table" "history" {
  name         = "history"
  hash_key     = "identifier"
  range_key    = "updatedAt"
  billing_mode = "PAY_PER_REQUEST"
  table_class  = "STANDARD_INFREQUENT_ACCESS"

  attribute {
    name = "identifier"
    type = "S"
  }

  attribute {
    name = "updatedAt"
    type = "S"
  }
}

# ================================================================
# DynamoDB Table history_dev
# ================================================================

resource "aws_dynamodb_table" "history_dev" {
  name         = "history_dev"
  hash_key     = "identifier"
  range_key    = "updatedAt"
  billing_mode = "PAY_PER_REQUEST"
  table_class  = "STANDARD_INFREQUENT_ACCESS"

  attribute {
    name = "identifier"
    type = "S"
  }

  attribute {
    name = "updatedAt"
    type = "S"
  }
}
