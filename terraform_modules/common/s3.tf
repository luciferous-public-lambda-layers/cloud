# ================================================================
# Lambda Artifacts Bucket
# ================================================================

resource "aws_s3_bucket" "lambda_artifacts" {
  bucket_prefix = "lambda-artifacts-"
}

# ================================================================
# Data Bucket
# ================================================================

resource "aws_s3_bucket" "layers_data" {
  bucket_prefix = "layers-data-"
}
