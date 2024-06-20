output "name" {
  description = "Amplify App name"
  value       = one(aws_amplify_app.default[*].name)
}

output "arn" {
  description = "Amplify App ARN"
  value       = one(aws_amplify_app.default[*].arn)
}

output "id" {
  description = "Amplify App Id"
  value       = one(aws_amplify_app.default[*].id)
}

output "default_domain" {
  description = "Amplify App domain (non-custom)"
  value       = one(aws_amplify_app.default[*].default_domain)
}

output "backend_environments" {
  description = "Created backend environments"
  value       = aws_amplify_backend_environment.default
}

output "branch_names" {
  description = "The names of the created Amplify branches"
  value       = values(aws_amplify_branch.default)[*].branch_name
}

output "webhooks" {
  description = "Created webhooks"
  value       = aws_amplify_webhook.default
}

output "domain_associations" {
  description = "Created domain associations"
  value       = aws_amplify_domain_association.default
}

