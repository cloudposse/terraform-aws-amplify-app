output "name" {
  description = "The name of the main Amplify resource"
  value       = one(aws_amplify_app.default[*].name)
}

output "arn" {
  description = "The ARN of the main Amplify resource"
  value       = one(aws_amplify_app.default[*].arn)
}

output "default_domain" {
  description = "The amplify domain (non-custom)"
  value       = one(aws_amplify_app.default[*].default_domain)
}
