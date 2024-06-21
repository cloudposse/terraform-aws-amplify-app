data "aws_ssm_parameter" "github_pat" {
  name            = var.github_personal_access_token_secret_path
  with_decryption = true
}

module "amplify_app" {
  source = "../../"

  access_token                        = data.aws_ssm_parameter.github_pat.value
  description                         = var.description
  repository                          = var.repository
  platform                            = var.platform
  oauth_token                         = var.oauth_token
  auto_branch_creation_config         = var.auto_branch_creation_config
  auto_branch_creation_patterns       = var.auto_branch_creation_patterns
  basic_auth_credentials              = var.basic_auth_credentials
  build_spec                          = var.build_spec
  enable_auto_branch_creation         = var.enable_auto_branch_creation
  enable_basic_auth                   = var.enable_basic_auth
  enable_branch_auto_build            = var.enable_branch_auto_build
  enable_branch_auto_deletion         = var.enable_branch_auto_deletion
  environment_variables               = var.environment_variables
  custom_rules                        = var.custom_rules
  iam_service_role_enabled            = var.iam_service_role_enabled
  iam_service_role_arn                = var.iam_service_role_arn
  iam_service_role_actions            = var.iam_service_role_actions
  environments                        = var.environments
  domains                             = var.domains
  attach_amplify_admin_managed_policy = var.attach_amplify_admin_managed_policy

  context = module.this.context
}
