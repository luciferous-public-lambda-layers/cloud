# ================================================================
# SSM Parameter Output
# ================================================================

resource "aws_ssm_parameter" "output_table_layers" {
  name  = "${var.prefix_output_ssm}/Tables/Layers"
  type  = "String"
  value = aws_dynamodb_table.layers.name
}

resource "aws_ssm_parameter" "output_table_layers_dev" {
  name  = "${var.prefix_output_ssm}/Tables/LayersDev"
  type  = "String"
  value = aws_dynamodb_table.layers_dev.name
}

resource "aws_ssm_parameter" "output_identity_pool" {
  name  = "${var.prefix_output_ssm}/IdentityPool"
  type  = "String"
  value = aws_cognito_identity_pool.identity.id
}