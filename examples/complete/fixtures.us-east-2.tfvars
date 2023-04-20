region = "us-east-2"

namespace = "eg"

environment = "ue2"

stage = "test"

name = "amplify"

# https://docs.aws.amazon.com/amplify/latest/userguide/getting-started.html
# The GitHub PAT needs to have the scope `admin:repo_hook`
# Refer to "Setting up the Amplify GitHub App for AWS CloudFormation, CLI, and SDK deployments"
# in https://docs.aws.amazon.com/amplify/latest/userguide/setting-up-GitHub-access.html
github_personal_access_token_secret_path = "/cpco-amplify-app-test-github-token"

platform = "WEB"

repository = "https://github.com/cloudposse/amplify-test2"

iam_service_role_enabled = true

# https://docs.aws.amazon.com/amplify/latest/userguide/ssr-CloudWatch-logs.html
iam_service_role_actions = [
  "logs:CreateLogStream",
  "logs:CreateLogGroup",
  "logs:DescribeLogGroups",
  "logs:PutLogEvents"
]

enable_auto_branch_creation = false

enable_branch_auto_build = true

enable_branch_auto_deletion = true

enable_basic_auth = false

auto_branch_creation_patterns = [
  "*",
  "*/**"
]

auto_branch_creation_config = {
  # Enable auto build for the created branches
  enable_auto_build = true
}

# The build spec for React
build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - yarn install
        build:
          commands:
            - yarn run build
      artifacts:
        baseDirectory: build
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

custom_rules = [
  {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }
]

environment_variables = {
  ENV = "test"
}

environments = {
  prod = {
    branch_name                 = "main"
    enable_auto_build           = true
    backend_enabled             = false
    enable_performance_mode     = true
    enable_pull_request_preview = false
    framework                   = "React"
    stage                       = "PRODUCTION"
  }
  dev = {
    branch_name                 = "dev"
    enable_auto_build           = true
    backend_enabled             = false
    enable_performance_mode     = false
    enable_pull_request_preview = true
    framework                   = "React"
    stage                       = "DEVELOPMENT"
  }
}

domain_config = {
  domain_name            = "mydomain.net"
  enable_auto_sub_domain = true
  wait_for_verification  = false
  sub_domain = [
    {
      branch_name = "main"
      prefix      = "prod"
    },
    {
      branch_name = "dev"
      prefix      = "dev"
    }
  ]
}
