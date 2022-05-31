variable "description" {
  type        = string
  description = "The description for an Amplify app."
  default     = null
}

variable "repository" {
  type        = string
  description = "The repository for an Amplify app."
  default     = null
}

variable "platform" {
  type        = string
  description = "The platform or framework for an Amplify app."
  default     = "WEB"
}

variable "access_token" {
  type        = string
  description = "The personal access token for a third-party source control system for an Amplify app. The personal access token is used to create a webhook and a read-only deploy key. The token is not stored."
  default     = null
}

variable "oauth_token" {
  type        = string
  description = "The OAuth token for a third-party source control system for an Amplify app. The OAuth token is used to create a webhook and a read-only deploy key. The OAuth token is not stored."
  default     = null
}

variable "auto_branch_creation_config" {
  type        = map(any)
  description = "The automated branch creation configuration for an Amplify app."
  default     = null
}

variable "auto_branch_creation_patterns" {
  type        = list(string)
  description = "The automated branch creation glob patterns for an Amplify app."
  default     = null
}

variable "basic_auth_credentials" {
  type        = string
  description = "The credentials for basic authorization for an Amplify app."
  default     = null
}

variable "build_spec" {
  type        = string
  description = "The [build specification](https://docs.aws.amazon.com/amplify/latest/userguide/build-settings.html) (build spec) for an Amplify app. If not provided then it will use the `amplify.yml` at the root of your project / branch."
  default     = null
}

variable "enable_auto_branch_creation" {
  type        = bool
  description = "Enables automated branch creation for an Amplify app."
  default     = false
}

variable "enable_basic_auth" {
  type        = bool
  description = "Enables basic authorization for an Amplify app. This will apply to all branches that are part of this app."
  default     = false
}

variable "enable_branch_auto_build" {
  type        = bool
  description = "Enables auto-building of branches for the Amplify App."
  default     = false
}

variable "enable_branch_auto_deletion" {
  type        = bool
  description = "Automatically disconnects a branch in the Amplify Console when you delete a branch from your Git repository."
  default     = false
}

variable "environment_variables" {
  type        = map(any)
  description = "The environment variables map for an Amplify app."
  default     = {}
}

variable "iam_service_role_arn" {
  type        = string
  description = "The AWS Identity and Access Management (IAM) service role for an Amplify app."
  default     = null
}

variable "custom_rules" {
  type        = list(any)
  description = "The custom rules to apply to the Amplify App."
  default     = []
}
