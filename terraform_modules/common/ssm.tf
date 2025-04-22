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

resource "aws_ssm_parameter" "output_role_arn_github_actions_publisher" {
  name  = "${var.prefix_output_ssm}/Publisher/ArnRolePublisher"
  type  = "String"
  value = aws_iam_role.github_actions_publisher.arn
}

resource "aws_ssm_parameter" "output_role_arn_cloudformation" {
  name  = "${var.prefix_output_ssm}/Publisher/ArnRoleCloudFormation"
  type  = "String"
  value = aws_iam_role.cloud_formation.arn
}

resource "aws_ssm_parameter" "output_name_event_bus" {
  name  = "${var.prefix_output_ssm}/Publisher/NameEventBus"
  type  = "String"
  value = aws_cloudwatch_event_bus.slack_error_notifier.name
}