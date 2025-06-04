locals {
  events = {
    name = {
      pipe = {
        github_actions_auto_publisher = "github-actions-auto-dispatcher_${random_string.pipe_github_actions_auto_dispatcher.result}"
      }
    }
  }
}

# ================================================================
# For Slack
# ================================================================

resource "aws_cloudwatch_event_connection" "slack_dummy" {
  authorization_type = "API_KEY"
  name               = "slack-dummy"

  auth_parameters {
    api_key {
      key   = "DUMMY"
      value = "dummy"
    }
  }
}

# ================================================================
# Slack Error Notifier
# ================================================================

resource "aws_cloudwatch_event_bus" "slack_error_notifier" {
  name = "error_notifier"
}

module "slack_error_notifier_01" {
  source = "../events_slack_webhook_destination"

  slack_incoming_webhook_url = var.slack_incoming_webhook_error_notifier_01
  api_destination_name       = "error_notifier_01"

  event_bus_name             = aws_cloudwatch_event_bus.slack_error_notifier.name
  iam_role_arn               = aws_iam_role.event_bridge_invoke_api_destination.arn
  connection_arn_slack_dummy = aws_cloudwatch_event_connection.slack_dummy.arn
}

module "slack_error_notifier_02" {
  source = "../events_slack_webhook_destination"

  slack_incoming_webhook_url = var.slack_incoming_webhook_error_notifier_02
  api_destination_name       = "error_notifier_02"

  event_bus_name             = aws_cloudwatch_event_bus.slack_error_notifier.name
  iam_role_arn               = aws_iam_role.event_bridge_invoke_api_destination.arn
  connection_arn_slack_dummy = aws_cloudwatch_event_connection.slack_dummy.arn
}

# ================================================================
# Github Actions Auto Dispatcher
# ================================================================

resource "random_string" "connection_github_actions_auto_dispatcher" {
  length  = 33
  lower   = true
  upper   = true
  numeric = true
  special = false
}

resource "aws_cloudwatch_event_connection" "github_actions_auto_dispatcher" {
  authorization_type = "API_KEY"
  name               = "github-actions-auto-dispatcher_${random_string.connection_github_actions_auto_dispatcher.result}"

  auth_parameters {
    api_key {
      key   = "Authorization"
      value = "token ${var.my_github_token}"
    }

    invocation_http_parameters {
      header {
        key             = "Accept"
        value           = "application/vnd.github.v3+json"
        is_value_secret = false
      }
    }
  }
}

resource "random_string" "api_destination_github_actions_auto_dispatcher" {
  length  = 33
  lower   = true
  upper   = true
  numeric = true
  special = false
}

resource "aws_cloudwatch_event_api_destination" "github_actions_auto_dispatcher" {
  connection_arn      = aws_cloudwatch_event_connection.github_actions_auto_dispatcher.arn
  http_method         = "POST"
  invocation_endpoint = "https://api.github.com/repos/${var.repository_publisher}/actions/workflows/${var.workflow_file_publisher}/dispatches"
  name                = "github-actions-auto-dispatcher_${random_string.api_destination_github_actions_auto_dispatcher.result}"
}

resource "random_string" "pipe_github_actions_auto_dispatcher" {
  length  = 33
  lower   = true
  upper   = true
  numeric = true
  special = false
}

resource "aws_pipes_pipe" "github_actions_auto_dispatcher" {
  role_arn = aws_iam_role.github_actions_auto_dispatcher.arn
  source   = aws_dynamodb_table.layers.stream_arn
  target   = aws_cloudwatch_event_api_destination.github_actions_auto_dispatcher.arn
  name     = local.events.name.pipe.github_actions_auto_publisher

  source_parameters {
    dynamodb_stream_parameters {
      starting_position = "LATEST"
      batch_size        = 1
    }

    filter_criteria {
      filter {
        pattern = jsonencode({
          dynamodb = {
            NewImage = {
              stateLayer = {
                S = [
                  {
                    equals-ignore-case = "QUEUED"
                  }
                ]
              }
            }
          }
        })
      }
    }
  }

  target_parameters {
    input_template = <<EOT
{
  "ref": "master",
  "inputs": {
    "identifier": <$.dynamodb.Keys.identifier.S>
  }
}
EOT
  }

  log_configuration {
    level = "ERROR"
    cloudwatch_logs_log_destination {
      log_group_arn = aws_cloudwatch_log_group.github_actions_auto_dispatcher.arn
    }
  }
}