# Basic repository configuration
variable "name" {
  description = "The name of the repository"
  type        = string
}

variable "description" {
  description = "A description of the repository"
  type        = string
  default     = null
}

variable "visibility" {
  description = "Can be public or private. If your organization is associated with an enterprise account using GitHub Enterprise Cloud (GHEC), you can also choose internal"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "Visibility must be one of: public, private, internal."
  }
}

# App installations
variable "app_installations" {
  description = "Map of app installations to be added to the repository"
  type        = any
  default     = {}
}

# Branch configuration
variable "default_branch" {
  description = "The default branch name"
  type        = string
  default     = "main"
}

variable "branches" {
  description = "Map of branches. Each entry can optionally include `branch_protection` for basic branch protection rules. Rulesets are configured separately via `rulesets`."
  type        = any
  default     = {}
}

variable "rulesets" {
  description = "Map of repository rulesets. Each ruleset has a unique key and can target one or more branches/tags via conditions.ref_name (include/exclude patterns). Supports multiple rulesets per repository with name, target (branch/tag), conditions, bypass_actors, and rules (pull_request, required_status_checks, etc.)."
  type        = any
  default     = {}
}

# Basic features
variable "auto_init" {
  description = "Set to true to produce an initial commit in the repository. Note: This will be automatically set to true if default_branch is not 'main' to ensure the repository is not empty."
  type        = bool
  default     = false
}

variable "has_issues" {
  description = "Set to true to enable the GitHub Issues features on the repository"
  type        = bool
  default     = true
}

variable "has_wiki" {
  description = "Set to true to enable the GitHub Wiki features on the repository"
  type        = bool
  default     = false
}

variable "has_projects" {
  description = "Set to true to enable the GitHub Projects features on the repository"
  type        = bool
  default     = false
}

# Merge settings
variable "allow_squash_merge" {
  description = "Set to false to disable squash merges on the repository"
  type        = bool
  default     = true
}

variable "allow_merge_commit" {
  description = "Set to false to disable merge commits on the repository"
  type        = bool
  default     = true
}

variable "squash_merge_commit_title" {
  description = "(Optional) Can be PR_TITLE or COMMIT_OR_PR_TITLE for a default squash merge commit title. Applicable only if allow_squash_merge is true."
  type        = string
  default     = "PR_TITLE"
}

variable "squash_merge_commit_message" {
  description = "(Optional) Can be PR_BODY, COMMIT_MESSAGES, or BLANK for a default squash merge commit message. Applicable only if allow_squash_merge is true."
  type        = string
  default     = "BLANK"
}

variable "merge_commit_title" {
  description = "(Optional) Can be PR_TITLE or COMMIT_OR_PR_TITLE for a default merge commit title. Applicable only if allow_merge is true."
  type        = string
  default     = "PR_TITLE"
}

variable "merge_commit_message" {
  description = "(Optional) Can be PR_BODY, COMMIT_MESSAGES, or BLANK for a default merge commit message. Applicable only if allow_merge is true."
  type        = string
  default     = "BLANK"
}

variable "allow_rebase_merge" {
  description = "Set to false to disable rebase merges on the repository"
  type        = bool
  default     = true
}

variable "delete_branch_on_merge" {
  description = "Automatically delete head branch after a pull request is merged"
  type        = bool
  default     = true
}

# Security
variable "vulnerability_alerts" {
  description = "Set to true to enable security alerts for vulnerable dependencies"
  type        = bool
  default     = true
}

variable "is_template" {
  description = "Set to true to tell GitHub that this is a template repository"
  type        = bool
  default     = false
}

variable "license_template" {
  description = "Use a template repository to create this resource. See Template Repositories below for more details"
  type        = string
  default     = null
}

# Topics
variable "topics" {
  description = "The list of topics of the repository"
  type        = list(string)
  default     = []
}

variable "archived" {
  description = "Specifies if the repository should be archived"
  type        = bool
  default     = false
}

variable "archive_on_destroy" {
  description = "Set to true to archive the repository instead of deleting on destroy"
  type        = bool
  default     = true
}

# Webhooks
variable "webhooks" {
  description = "Map of webhooks"
  type = map(object({
    events = list(string)
    active = bool
    configuration = object({
      url          = string
      content_type = string
      secret       = string
      insecure_ssl = bool
    })
  }))
  default = {}
}

# Files
variable "files" {
  description = "Map of files to create in the repository"
  type = map(object({
    branch              = string
    file                = string
    content             = string
    commit_message      = string
    commit_author       = string
    commit_email        = string
    overwrite_on_create = bool
  }))
  default = {}
}

# Labels
variable "labels" {
  description = "Map of issue labels"
  type = map(object({
    name        = string
    color       = string
    description = string
  }))
  default = {}
}

# Deploy keys
variable "deploy_keys" {
  description = "Map of deploy keys"
  type = map(object({
    title     = string
    key       = string
    read_only = bool
  }))
  default = {}
}

# Team permissions
variable "team_permissions" {
  description = "Map of team permissions for the repository. Key is team_id, value is permission"
  type        = map(string)
  default     = {}
}

# User permissions
variable "user_permissions" {
  description = "Map of user permissions for the repository. Key is username, value is permission"
  type        = map(string)
  default     = {}
}

# Repository environments
variable "environments" {
  description = "Map of repository environments with their configuration"
  type = map(object({
    environment         = optional(string) # Name of the environment (defaults to key)
    wait_timer          = optional(number) # Amount of time to wait before allowing deployments (in minutes)
    prevent_self_review = optional(bool)   # Prevent admins and bypassers from reviewing their own deployments
    reviewers = optional(object({
      users = optional(list(string), []) # List of GitHub usernames that can review deployments
      teams = optional(list(string), []) # List of team slugs that can review deployments
    }), null)
    deployment_branch_policy = optional(object({
      protected_branches     = optional(bool, false) # Only branches matching this pattern can deploy to this environment
      custom_branch_policies = optional(bool, false) # Custom branch policies can be defined
    }), null)
    secrets   = optional(map(string), {}) # Map of secret names to secret values
    variables = optional(map(string), {}) # Map of variable names to variable values
  }))
  default = {}
}

# Repository-level secrets
variable "secrets" {
  description = "Map of repository-level GitHub Actions secrets. Key is the secret name, value is the secret value."
  type        = map(string)
  default     = {}
  sensitive   = true
}

# Repository-level variables
variable "variables" {
  description = "Map of repository-level GitHub Actions variables. Key is the variable name, value is the variable value."
  type        = map(string)
  default     = {}
}

