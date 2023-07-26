output "name" {
  description = "Amplify App name"
  value       = module.amplify_app.name
}

output "arn" {
  description = "Amplify App ARN"
  value       = module.amplify_app.arn
}

output "default_domain" {
  description = "Amplify App domain (non-custom)"
  value       = module.amplify_app.default_domain
}

output "backend_environments" {
  description = "Created backend environments"
  value       = module.amplify_app.backend_environments
}

output "branch_names" {
  description = "The names of the created Amplify branches"
  value       = module.amplify_app.branch_names
}

output "webhooks" {
  description = "Created webhooks"
  value       = module.amplify_app.webhooks
}

output "domain_associations" {
  description = "Created domain associations"
  value       = module.amplify_app.domain_associations
}
