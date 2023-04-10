output "name" {
  description = "The name of the main Amplify resource"
  value       = module.amplify_app.name
}

output "arn" {
  description = "The ARN of the main Amplify resource"
  value       = module.amplify_app.arn
}

output "default_domain" {
  description = "The amplify domain (non-custom)"
  value       = module.amplify_app.default_domain
}
