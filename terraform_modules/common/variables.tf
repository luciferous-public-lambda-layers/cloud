variable "system_name" {
  type     = string
  nullable = false
}

variable "region" {
  type     = string
  nullable = false
}

variable "layer_arn_base" {
  type     = string
  nullable = false
}

variable "prefix_output_ssm" {
  type     = string
  nullable = false
}

variable "slack_incoming_webhook_error_notifier_01" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "slack_incoming_webhook_error_notifier_02" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "my_github_token" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "repository_publisher" {
  type      = string
  nullable  = false
  sensitive = false
}

variable "workflow_file_publisher" {
  type      = string
  nullable  = false
  sensitive = false
}
