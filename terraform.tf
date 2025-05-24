# ================================================================
# Config
# ================================================================

terraform {
  required_version = "1.11.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94"
    }
  }

  backend "s3" {
    bucket       = null
    key          = null
    region       = null
    use_lockfile = true
  }
}

# ================================================================
# Provider
# ================================================================

provider "aws" {
  region = var.REGION

  default_tags {
    tags = {
      SystemName = var.SYSTEM_NAME
    }
  }
}

# ================================================================
# Modules
# ================================================================

module "common" {
  source = "./terraform_modules/common"

  system_name = var.SYSTEM_NAME
  region      = var.REGION

  layer_arn_base    = var.LAYER_ARN_BASE
  prefix_output_ssm = "/Output"

  slack_incoming_webhook_error_notifier_01 = var.SLACK_INCOMING_WEBHOOK_ERROR_NOTIFIER_01
  slack_incoming_webhook_error_notifier_02 = var.SLACK_INCOMING_WEBHOOK_ERROR_NOTIFIER_02

  my_github_token = var.MY_GITHUB_TOKEN
}

# ================================================================
# Variables
# ================================================================

variable "SYSTEM_NAME" {
  type     = string
  nullable = false
}

variable "REGION" {
  type     = string
  nullable = false
}

variable "LAYER_ARN_BASE" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "SLACK_INCOMING_WEBHOOK_ERROR_NOTIFIER_01" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "SLACK_INCOMING_WEBHOOK_ERROR_NOTIFIER_02" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "MY_GITHUB_TOKEN" {
  type      = string
  nullable  = false
  sensitive = true
}