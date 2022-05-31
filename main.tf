locals {
  enabled = module.this.enabled
}

resource "aws_amplify_app" "this" {
  count = local.enabled ? 1 : 0

  name        = module.this.id
  description = var.description
  repository  = var.repository
  platform    = var.platform

  access_token = var.access_token
  oauth_token  = var.oauth_token

  auto_branch_creation_config   = var.auto_branch_creation_config
  auto_branch_creation_patterns = var.auto_branch_creation_patterns

  basic_auth_credentials = var.basic_auth_credentials

  build_spec = var.build_spec

  enable_auto_branch_creation = var.enable_auto_branch_creation
  enable_basic_auth           = var.enable_basic_auth
  enable_branch_auto_build    = var.enable_branch_auto_build
  enable_branch_auto_deletion = var.enable_branch_auto_deletion

  environment_variables = var.environment_variables
  iam_service_role_arn  = var.iam_service_role_arn

  dynamic "custom_rule" {
    for_each = var.custom_rules
    iterator = rule

    content {
      condition = lookup(rule.value, "condition", null)
      source    = rule.value.source
      status    = lookup(rule.value, "status", null)
      target    = rule.value.target
    }
  }

  dynamic "auto_branch_creation_config" {
    for_each = var.auto_branch_creation_config != null ? [true] : []
    iterator = config

    content {
      basic_auth_credentials        = lookup(config.value, "basic_auth_credentials", null)
      build_spec                    = lookup(config.value, "build_spec", null)
      enable_auto_build             = lookup(config.value, "enable_auto_build", null)
      enable_basic_auth             = lookup(config.value, "enable_basic_auth", null)
      enable_performance_mode       = lookup(config.value, "enable_performance_mode", null)
      enable_pull_request_preview   = lookup(config.value, "enable_pull_request_preview", null)
      environment_variables         = lookup(config.value, "environment_variables", null)
      framework                     = lookup(config.value, "framework", null)
      pull_request_environment_name = lookup(config.value, "pull_request_environment_name", null)
      stage                         = lookup(config.value, "stage", null)
    }
  }

  tags = module.this.tags

  lifecycle {
    ignore_changes = [platform, custom_rule]
  }
}
