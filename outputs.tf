output "repositories" {
  description = "Map of created repositories keyed by name."
  value = {
    for k, m in module.repository : k => {
      id             = m.repository_id
      name           = m.repository_name
      full_name      = m.repository_full_name
      html_url       = m.repository_html_url
      ssh_url        = m.repository_ssh_url
      https_url      = m.repository_https_url
      visibility     = m.repository_visibility
      default_branch = m.repository_default_branch
    }
  }
}

output "branch_protection" {
  description = "Map of branch protection rules keyed by repository name."
  value = {
    for k, m in module.repository : k => m.branch_protection
  }
}

output "environments" {
  description = "Map of repository environments keyed by repository name."
  value = {
    for k, m in module.repository : k => m.environments
  }
}
