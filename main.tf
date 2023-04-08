locals {
  enabled = module.this.enabled

  iam_role_enabled = local.enabled && var.iam_service_role_arn == null

  iam_service_role_arn = local.iam_role_enabled ? module.role.arn : var.iam_service_role_arn
}

data "aws_iam_policy_document" "default" {
  count = local.enabled ? 1 : 0

  statement {
    sid       = "AmplifyAccess"
    effect    = "Allow"
    resources = ["*"]

    # source: https://github.com/aws-amplify/amplify-cli/issues/4322#issuecomment-455022473
    actions = [
      "appsync:*",
      "amplify:*",
      "apigateway:POST",
      "apigateway:DELETE",
      "apigateway:PATCH",
      "apigateway:PUT",
      "cloudformation:CreateStack",
      "cloudformation:CreateStackSet",
      "cloudformation:DeleteStack",
      "cloudformation:DeleteStackSet",
      "cloudformation:DescribeStackEvents",
      "cloudformation:DescribeStackResource",
      "cloudformation:DescribeStackResources",
      "cloudformation:DescribeStackSet",
      "cloudformation:DescribeStackSetOperation",
      "cloudformation:DescribeStacks",
      "cloudformation:UpdateStack",
      "cloudformation:UpdateStackSet",
      "cloudfront:CreateCloudFrontOriginAccessIdentity",
      "cloudfront:CreateDistribution",
      "cloudfront:DeleteCloudFrontOriginAccessIdentity",
      "cloudfront:DeleteDistribution",
      "cloudfront:GetCloudFrontOriginAccessIdentity",
      "cloudfront:GetCloudFrontOriginAccessIdentityConfig",
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:TagResource",
      "cloudfront:UntagResource",
      "cloudfront:UpdateCloudFrontOriginAccessIdentity",
      "cloudfront:UpdateDistribution",
      "cognito-identity:CreateIdentityPool",
      "cognito-identity:DeleteIdentityPool",
      "cognito-identity:DescribeIdentity",
      "cognito-identity:DescribeIdentityPool",
      "cognito-identity:SetIdentityPoolRoles",
      "cognito-identity:UpdateIdentityPool",
      "cognito-idp:CreateUserPool",
      "cognito-idp:CreateUserPoolClient",
      "cognito-idp:DeleteUserPool",
      "cognito-idp:DeleteUserPoolClient",
      "cognito-idp:DescribeUserPool",
      "cognito-idp:UpdateUserPool",
      "cognito-idp:UpdateUserPoolClient",
      "dynamodb:CreateTable",
      "dynamodb:DeleteItem",
      "dynamodb:DeleteTable",
      "dynamodb:DescribeTable",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:UpdateTable",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:GetRole",
      "iam:GetUser",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:UpdateRole",
      "lambda:AddPermission",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:InvokeAsync",
      "lambda:InvokeFunction",
      "lambda:RemovePermission",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "s3:*"
    ]
  }
}

module "role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.17.0"

  enabled = local.iam_role_enabled

  policy_description = "Allow Amplify FullAccess"
  role_description   = "IAM role with permissions for Amplify to perform actions on AWS resources"

  principals = {
    # AWS = ["arn:aws:iam::123456789012:role/workers"]
    Service = ["amplify.amazonaws.com"]
  }

  policy_documents = [
    one(data.aws_iam_policy_document.default[*].json),
  ]

  context = module.this.context
}

resource "aws_amplify_app" "default" {
  count = local.enabled ? 1 : 0

  name        = module.this.id
  description = var.description
  repository  = var.repository
  platform    = var.platform

  access_token = var.access_token
  oauth_token  = var.oauth_token

  auto_branch_creation_patterns = var.auto_branch_creation_patterns

  basic_auth_credentials = var.basic_auth_credentials

  build_spec = var.build_spec

  enable_auto_branch_creation = var.enable_auto_branch_creation
  enable_basic_auth           = var.enable_basic_auth
  enable_branch_auto_build    = var.enable_branch_auto_build
  enable_branch_auto_deletion = var.enable_branch_auto_deletion

  environment_variables = var.environment_variables
  iam_service_role_arn  = local.iam_service_role_arn

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
  for_each = local.enabled ? {
    for key, value in var.environments :
    key => value
    if lookup(value, "backend_enabled", false)
  } : {}

  app_id           = one(aws_amplify_app.default[*].id)
  environment_name = lookup(each.value, "branch_name", each.key)
}

resource "aws_amplify_branch" "default" {
  for_each = local.enabled ? var.environments : {}

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

resource "aws_amplify_domain_association" "branches" {
  count                  = local.enabled && var.domain_name != "" ? 1 : 0
  app_id                 = aws_amplify_app.this.0.id
  domain_name            = var.domain_name
  enable_auto_sub_domain = true
  wait_for_verification  = false

  sub_domain {
    branch_name = aws_amplify_branch.primary.0.branch_name
    prefix      = var.subdomain_primary_branch
  }
}

resource "aws_amplify_webhook" "default" {
  for_each = local.enabled ? var.environments : {}

  app_id      = one(aws_amplify_app.default[*].id)
  branch_name = lookup(each.value, "branch_name", each.key)
  description = format("trigger-%s", lookup(each.value, "branch_name", each.key))

  # NOTE: We trigger the webhook via local-exec so as to kick off the first build on creation of Amplify App.
  provisioner "local-exec" {
    command = "curl -X POST -d {} '${aws_amplify_webhook.default[each.key].url}&operation=startbuild' -H 'Content-Type:application/json'"
  }
}
