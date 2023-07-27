variable "domain_config" {
  type = object({
    domain_name            = string
    enable_auto_sub_domain = optional(bool, false)
    wait_for_verification  = optional(bool, false)
    sub_domain = list(object({
      branch_name = string
      prefix      = string
    }))
  })
  description = <<-EOT
    DEPRECATED: Use the `domains` variable instead.
    Amplify custom domain configuration.
    EOT
  default     = null
}

locals {
  domain_config = local.enabled && var.domain_config != null ? {
    (var.domain_config.domain_name) = {
      enable_auto_sub_domain = lookup(var.domain_config, "enable_auto_sub_domain", false)
      wait_for_verification  = lookup(var.domain_config, "wait_for_verification", false)
      sub_domain             = var.domain_config.sub_domain
    }
  } : null
}
