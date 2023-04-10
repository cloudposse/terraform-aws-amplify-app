region = "us-east-2"

namespace = "eg"

environment = "ue2"

stage = "test"

name = "amplify"

repository = "https://github.com/aws-samples/aws-starter-react-for-github-actions"

enable_auto_branch_creation = true

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
