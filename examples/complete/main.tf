module "amplify_app" {
  source = "../../"

  description                   = var.description
  repository                    = var.repository
  platform                      = var.platform
  access_token                  = var.access_token
  oauth_token                   = var.oauth_token
  auto_branch_creation_config   = var.auto_branch_creation_config
  auto_branch_creation_patterns = var.auto_branch_creation_patterns
  basic_auth_credentials        = var.basic_auth_credentials
  build_spec                    = var.build_spec
  enable_auto_branch_creation   = var.enable_auto_branch_creation
  enable_basic_auth             = var.enable_basic_auth
  enable_branch_auto_build      = var.enable_branch_auto_build
  enable_branch_auto_deletion   = var.enable_branch_auto_deletion
  environment_variables         = var.environment_variables
  custom_rules                  = var.custom_rules
  iam_service_role_enabled      = var.iam_service_role_enabled
  iam_service_role_arn          = var.iam_service_role_arn
  environments                  = var.environments
}
