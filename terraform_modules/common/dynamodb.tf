terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
# ================================================================
# DynamoDB Table layers
# ================================================================

resource "aws_dynamodb_table" "layers" {
  name         = "layers"
  hash_key     = "identifier"
  billing_mode = "PAY_PER_REQUEST"
  table_class  = "STANDARD_INFREQUENT_ACCESS"

  attribute {
    name = "identifier"
    type = "S"
  }
}

# ================================================================
# DynamoDB Table layers_dev
# ================================================================

resource "aws_dynamodb_table" "layers_dev" {
  name         = "layers_dev"
  hash_key     = "identifier"
  billing_mode = "PAY_PER_REQUEST"
  table_class  = "STANDARD_INFREQUENT_ACCESS"

  attribute {
    name = "identifier"
    type = "S"
  }
}
