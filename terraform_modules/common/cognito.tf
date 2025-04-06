resource "aws_cognito_identity_pool" "identity" {
  identity_pool_name               = "identity"
  allow_unauthenticated_identities = true
}

resource "aws_cognito_identity_pool_roles_attachment" "identity" {
  identity_pool_id = aws_cognito_identity_pool.identity.id
  roles = {
    "unauthenticated" = aws_iam_role.cognito_unauthenticated.arn
  }
}