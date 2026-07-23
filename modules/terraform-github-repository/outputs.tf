# Repository basic outputs
output "repository_id" {
  description = "The ID of the repository"
  value       = github_repository.this.id
}

output "repository_name" {
  description = "The name of the repository"
  value       = github_repository.this.name
}

output "repository_full_name" {
  description = "The full name of the repository"
  value       = github_repository.this.full_name
}

output "repository_html_url" {
  description = "The URL to view the repository on GitHub"
  value       = github_repository.this.html_url
}

output "repository_ssh_url" {
  description = "The SSH URL to clone the repository"
  value       = github_repository.this.ssh_clone_url
}

output "repository_https_url" {
  description = "The HTTPS URL to clone the repository"
  value       = github_repository.this.http_clone_url
}

output "repository_description" {
  description = "The description of the repository"
  value       = github_repository.this.description
}

output "repository_visibility" {
  description = "The visibility of the repository"
  value       = github_repository.this.visibility
}

output "repository_topics" {
  description = "The topics of the repository"
  value       = github_repository.this.topics
}

output "repository_archived" {
  description = "Whether the repository is archived"
  value       = github_repository.this.archived
}

output "repository_default_branch" {
  description = "The default branch of the repository"
  value       = github_branch_default.this.branch
}

# Branch protection output
output "branch_protection" {
  description = "The branch protection rules configured"
  value       = github_branch_protection.this
}

# Webhooks output
output "webhooks" {
  description = "The webhooks configured for the repository"
  value       = github_repository_webhook.this
}

# Files output
output "files" {
  description = "The files created in the repository"
  value       = github_repository_file.this
}

# Labels output
output "labels" {
  description = "The labels created in the repository"
  value       = github_issue_label.this
}

# Deploy keys output
output "deploy_keys" {
  description = "The deploy keys configured for the repository"
  value       = github_repository_deploy_key.this
}

# Environments output
output "environments" {
  description = "The environments configured for the repository"
  value       = github_repository_environment.this
}

# Repository-level secrets output
output "secrets" {
  description = "The repository-level secrets configured"
  value       = github_actions_secret.this
  sensitive   = true
}

# Repository-level variables output
output "variables" {
  description = "The repository-level variables configured"
  value       = github_actions_variable.this
}

# Environment-level secrets output
output "environment_secrets" {
  description = "The environment-level secrets configured"
  value       = github_actions_environment_secret.this
  sensitive   = true
}

# Environment-level variables output
output "environment_variables" {
  description = "The environment-level variables configured"
  value       = github_actions_environment_variable.this
}
