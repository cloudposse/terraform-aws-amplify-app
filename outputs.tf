output "arn" {
  description = "The ARN of the main Amplify resource."
  value       = join("", aws_amplify_app.default.*.arn)
}

output "default_domain" {
  description = "The amplify domain (non-custom)."
  value       = join("", aws_amplify_app.default.*.default_domain)
}
