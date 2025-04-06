locals {
  iam = {
    effect = {
      allow = "Allow"
    }
  }
}

# ================================================================
# Assume Role Policy Document
# ================================================================

data "aws_iam_policy_document" "assume_role_policy_event_bridge" {
  policy_id = "assume_role_policy_event_bridge"
  statement {
    sid     = "AssumeRolePolicyEventBridge"
    effect  = local.iam.effect.allow
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy_lambda" {
  policy_id = "assume_role_policy_lambda"
  statement {
    sid     = "AssumeRolePolicyLambda"
    effect  = local.iam.effect.allow
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy_cognito" {
  policy_id = "assume_role_policy_cognito"
  statement {
    sid     = "AssumeRolePolicyCognito"
    effect  = local.iam.effect.allow
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      identifiers = ["cognito-identity.amazonaws.com"]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      values   = [aws_cognito_identity_pool.identity.id]
      variable = "cognito-identity.amazonaws.com:aud"
    }
    condition {
      test     = "ForAnyValue:StringLike"
      values   = ["unauthenticated"]
      variable = "cognito-identity.amazonaws.com:amr"
    }
  }
}

# ================================================================
# Policy EventBridge Put Events
# ================================================================

data "aws_iam_policy_document" "policy_event_bridge_put_events" {
  policy_id = "policy_event_bridge_put_events"
  statement {
    sid       = "AllowEventBridgePutEvents"
    effect    = local.iam.effect.allow
    actions   = ["events:PutEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "event_bridge_put_events" {
  policy = data.aws_iam_policy_document.policy_event_bridge_put_events.json
}

# ================================================================
# Policy EventBridge Invoke API Destination
# ================================================================

data "aws_iam_policy_document" "policy_event_bridge_invoke_api_destination" {
  policy_id = "policy_event_bridge_invoke_api_destination"
  statement {
    sid       = "PolicyEventBridgeInvokeApiDestination"
    effect    = local.iam.effect.allow
    actions   = ["events:InvokeApiDestination"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "event_bridge_invoke_api_destination" {
  policy = data.aws_iam_policy_document.policy_event_bridge_invoke_api_destination.json
}

# ================================================================
# Policy Cognito Unauthenticated
# ================================================================

data "aws_iam_policy_document" "policy_cognito_unauthenticated" {
  policy_id = "policy_cognito_unauthenticated"
  statement {
    sid    = "PolicyCognitoUnauthenticated"
    effect = local.iam.effect.allow
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]
    resources = [
      aws_dynamodb_table.layers.arn,
      "${aws_dynamodb_table.layers.arn}/index/*",
      aws_dynamodb_table.layers_dev.arn,
      "${aws_dynamodb_table.layers_dev.arn}/index/*"
    ]
  }
}

resource "aws_iam_policy" "cognito_unauthenticated" {
  policy = data.aws_iam_policy_document.policy_cognito_unauthenticated.json
}

# ================================================================
# Role Lambda Error Processor
# ================================================================

resource "aws_iam_role" "lambda_error_processor" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_error_processor" {
  for_each = {
    a = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    b = aws_iam_policy.event_bridge_put_events.arn
  }
  policy_arn = each.value
  role       = aws_iam_role.lambda_error_processor.name
}

# ================================================================
# Role EventBridge Invoke API Destination
# ================================================================

resource "aws_iam_role" "event_bridge_invoke_api_destination" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_event_bridge.json
}

resource "aws_iam_role_policy_attachment" "event_bridge_invoke_api_destination" {
  for_each = {
    a = aws_iam_policy.event_bridge_invoke_api_destination.arn
  }
  policy_arn = each.value
  role       = aws_iam_role.event_bridge_invoke_api_destination.name
}

# ================================================================
# Role Cognito Unauthenticated
# ================================================================

resource "aws_iam_role" "cognito_unauthenticated" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_cognito.json
}

resource "aws_iam_role_policy_attachment" "cognito_unauthenticated" {
  for_each = {
    a = aws_iam_policy.cognito_unauthenticated.arn
  }
  policy_arn = each.value
  role       = aws_iam_role.cognito_unauthenticated.name
}
