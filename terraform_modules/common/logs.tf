resource "aws_cloudwatch_log_group" "github_actions_auto_dispatcher" {
  name              = "/custom/pipe/${local.events.name.pipe.github_actions_auto_publisher}"
  retention_in_days = 14
}