region = "us-east-2"

namespace = "eg"

environment = "ue2"

stage = "test"

name = "amplify"

platform = "WEB"

repository = "https://github.com/cloudposse/amplify-test2"

iam_service_role_enabled = false

enable_auto_branch_creation = false

enable_branch_auto_build = true

enable_branch_auto_deletion = true

enable_basic_auth = false

auto_branch_creation_patterns = [
  "*",
  "*/**"
]

auto_branch_creation_config = {
  # Enable auto build for the created branch
  enable_auto_build = true
}

# The build spec for React
build_spec = <<-EOT
    version: 0.1
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

environments = {}
