locals {
  enabled = module.this.enabled

  iam_role_enabled = local.enabled && var.iam_service_role_arn == null

  iam_service_role_arn = local.iam_role_enabled ? module.role.arn : var.iam_service_role_arn

  environments = { for k, v in var.environments : k => v if local.enabled }
}

resource "aws_amplify_app" "default" {
  count = local.enabled ? 1 : 0

  name        = module.this.id
  description = var.description
  repository  = var.repository
  platform    = var.platform

  access_token                  = var.access_token
  oauth_token                   = var.oauth_token
  auto_branch_creation_patterns = var.auto_branch_creation_patterns
  basic_auth_credentials        = var.basic_auth_credentials
  build_spec                    = var.build_spec
  enable_auto_branch_creation   = var.enable_auto_branch_creation
  enable_basic_auth             = var.enable_basic_auth
  enable_branch_auto_build      = var.enable_branch_auto_build
  enable_branch_auto_deletion   = var.enable_branch_auto_deletion
  environment_variables         = var.environment_variables
  iam_service_role_arn          = local.iam_service_role_arn

  dynamic "custom_rule" {
    for_each = var.custom_rules

    content {
      condition = lookup(custom_rule.value, "condition", null)
      source    = custom_rule.value.source
      status    = lookup(custom_rule.value, "status", null)
      target    = custom_rule.value.target
    }
  }

  dynamic "auto_branch_creation_config" {
    for_each = var.auto_branch_creation_config != null ? [true] : []

    content {
      basic_auth_credentials        = lookup(var.auto_branch_creation_config, "basic_auth_credentials", null)
      build_spec                    = lookup(var.auto_branch_creation_config, "build_spec", null)
      enable_auto_build             = lookup(var.auto_branch_creation_config, "enable_auto_build", null)
      enable_basic_auth             = lookup(var.auto_branch_creation_config, "enable_basic_auth", null)
      enable_performance_mode       = lookup(var.auto_branch_creation_config, "enable_performance_mode", null)
      enable_pull_request_preview   = lookup(var.auto_branch_creation_config, "enable_pull_request_preview", null)
      environment_variables         = lookup(var.auto_branch_creation_config, "environment_variables", null)
      framework                     = lookup(var.auto_branch_creation_config, "framework", null)
      pull_request_environment_name = lookup(var.auto_branch_creation_config, "pull_request_environment_name", null)
      stage                         = lookup(var.auto_branch_creation_config, "stage", null)
    }
  }

  tags = module.this.tags

  lifecycle {
    ignore_changes = [platform, custom_rule]
  }
}

resource "aws_amplify_backend_environment" "default" {
  for_each = { for k, v in local.environments : k => v if lookup(v, "backend_enabled", false) }

  app_id           = one(aws_amplify_app.default[*].id)
  environment_name = lookup(each.value, "branch_name", each.key)
}

resource "aws_amplify_branch" "default" {
  for_each = local.environments

  app_id                  = one(aws_amplify_app.default[*].id)
  branch_name             = lookup(each.value, "branch_name", each.key)
  display_name            = lookup(each.value, "branch_name", each.key)
  backend_environment_arn = lookup(each.value, "backend_enabled", false) ? aws_amplify_backend_environment.default[each.key].arn : null

  environment_variables = lookup(each.value, "environment_variables", {})

  enable_basic_auth      = var.enable_basic_auth
  basic_auth_credentials = null

  tags = module.this.tags

  lifecycle {
    ignore_changes = [framework]
  }
}

resource "aws_amplify_domain_association" "default" {
  for_each = { for k, v in local.environments : k => v if lookup(v, "domain_name", null) != null && lookup(v, "domain_name", "") != "" }

  app_id                 = one(aws_amplify_app.default[*].id)
  domain_name            = each.value.domain_name
  enable_auto_sub_domain = lookup(each.value, "enable_auto_sub_domain", true)
  wait_for_verification  = lookup(each.value, "wait_for_verification", false)

  dynamic "sub_domain" {
    for_each = lookup(each.value, "sub_domains", {})

    content {
      branch_name = sub_domain.value.branch_name
      prefix      = sub_domain.value.prefix
    }
  }
}

resource "aws_amplify_webhook" "default" {
  for_each = { for k, v in local.environments : k => v if lookup(v, "webhook_enabled", null) != null && lookup(v, "webhook_enabled", false) }

  app_id      = one(aws_amplify_app.default[*].id)
  branch_name = lookup(each.value, "branch_name", each.key)
  description = format("trigger-%s", lookup(each.value, "branch_name", each.key))

  # NOTE: We trigger the webhook via local-exec so as to kick off the first build on creation of Amplify App
  provisioner "local-exec" {
    command = "curl -X POST -d {} '${aws_amplify_webhook.default[each.key].url}&operation=startbuild' -H 'Content-Type:application/json'"
  }
}
