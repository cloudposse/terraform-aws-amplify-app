locals {
  create_iam_role = local.enabled && var.iam_service_role_enabled && length(var.iam_service_role_arn) == 0

  iam_service_role_arn = try(local.create_iam_role ? module.role.arn : var.iam_service_role_arn[0], null)

  # source: https://github.com/aws-amplify/amplify-cli/issues/4322#issuecomment-455022473
  default_actions = [
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
    "s3:*",
    "logs:CreateLogStream",
    "logs:CreateLogGroup",
    "logs:DescribeLogGroups",
    "logs:PutLogEvents"
  ]

  actions = length(var.iam_service_role_actions) > 0 ? var.iam_service_role_actions : local.default_actions
}

data "aws_iam_policy_document" "default" {
  count = local.create_iam_role ? 1 : 0

  statement {
    sid       = "AmplifyAccess"
    effect    = "Allow"
    resources = ["*"]
    actions   = local.actions
  }
}

module "role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.18.0"

  enabled = local.create_iam_role

  policy_description = "IAM policy for Amplify to perform actions on AWS resources"
  role_description   = "IAM role with permissions for Amplify to perform actions on AWS resources"

  principals = {
    # AWS = ["arn:aws:iam::123456789012:role/workers"]
    Service = ["amplify.amazonaws.com"]
  }

  policy_documents = [
    one(data.aws_iam_policy_document.default[*].json)
  ]

  managed_policy_arns = var.attach_amplify_admin_managed_policy ? ["arn:aws:iam::aws:policy/AdministratorAccess-Amplify"] : []

  context = module.this.context
}
