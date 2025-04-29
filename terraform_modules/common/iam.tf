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

data "aws_iam_policy_document" "assume_role_policy_github" {
  policy_id = "assume_role_policy_github"
  statement {
    sid     = "AssumeRolePolicyGithub"
    effect  = local.iam.effect.allow
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
      type        = "Federated"
    }
    condition {
      test     = "StringLike"
      values   = ["repo:luciferous-public-lambda-layers/*"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

data "aws_iam_policy_document" "assume_role_cloud_formation" {
  policy_id = "assume_role_policy_cloud_formation"
  statement {
    sid     = "AssumeRolePolicyCloudFormation"
    effect  = local.iam.effect.allow
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["cloudformation.amazonaws.com"]
      type        = "Service"
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
# Policy Github Actions Publisher
# ================================================================

data "aws_iam_policy_document" "policy_github_actions_publisher" {
  policy_id = "policy_github_actions_publisher"
  statement {
    sid    = "PolicyCloudFormation"
    effect = local.iam.effect.allow
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:DeleteObject",
      "s3:DeleteBucket",
      "cloudformation:*",
      "iam:PassRole",
      "lambda:ListLayerVersions",
      "lambda:ListLayers",
      "dynamodb:ListTables",
      "events:PutEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "PolicyDynamoDB"
    effect = local.iam.effect.allow
    actions = [
      "dynamodb:GetItem",
      "dynamodb:UpdateItem"
    ]
    resources = [aws_dynamodb_table.layers.arn]
  }
}

resource "aws_iam_policy" "github_actions_publisher" {
  policy = data.aws_iam_policy_document.policy_github_actions_publisher.json
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

# ================================================================
# Role Lambda Insert History
# ================================================================

resource "aws_iam_role" "lambda_insert_history" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_lambda.json
}
resource "aws_iam_role_policy_attachment" "lambda_insert_history" {
  for_each = {
    a = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    b = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  }
  policy_arn = each.value
  role       = aws_iam_role.lambda_insert_history.name
}

# ================================================================
# Role Github Actions Publisher
# ================================================================

resource "aws_iam_role" "github_actions_publisher" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_github.json
}

resource "aws_iam_role_policy_attachment" "github_actions_publisher" {
  for_each = {
    a = aws_iam_policy.github_actions_publisher.arn
  }
  policy_arn = each.value
  role       = aws_iam_role.github_actions_publisher.name
}

# ================================================================
# Role CloudFormation
# ================================================================

resource "aws_iam_role" "cloud_formation" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_cloud_formation.json
}

resource "aws_iam_role_policy_attachment" "cloud_formation" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.cloud_formation.name
}