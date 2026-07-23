module "repository" {
  source   = "./modules/terraform-github-repository"
  for_each = var.repository_parameters

  name        = each.key
  description = try(each.value.description, var.repository_defaults.description, "")
  visibility  = try(each.value.visibility, var.repository_defaults.visibility, "private")
  auto_init   = try(each.value.auto_init, var.repository_defaults.auto_init, true)

  default_branch = try(each.value.default_branch, var.repository_defaults.default_branch, "main")
  branches       = try(each.value.branches, var.repository_defaults.branches, {})
  rulesets       = try(each.value.rulesets, var.repository_defaults.rulesets, {})

  has_issues   = try(each.value.has_issues, var.repository_defaults.has_issues, true)
  has_wiki     = try(each.value.has_wiki, var.repository_defaults.has_wiki, false)
  has_projects = try(each.value.has_projects, var.repository_defaults.has_projects, false)

  allow_squash_merge = try(each.value.allow_squash_merge, var.repository_defaults.allow_squash_merge, true)
  allow_merge_commit = try(each.value.allow_merge_commit, var.repository_defaults.allow_merge_commit, true)
  allow_rebase_merge = try(each.value.allow_rebase_merge, var.repository_defaults.allow_rebase_merge, true)

  delete_branch_on_merge = try(each.value.delete_branch_on_merge, var.repository_defaults.delete_branch_on_merge, true)

  squash_merge_commit_title   = try(each.value.squash_merge_commit_title, var.repository_defaults.squash_merge_commit_title, "PR_TITLE")
  squash_merge_commit_message = try(each.value.squash_merge_commit_message, var.repository_defaults.squash_merge_commit_message, "BLANK")

  merge_commit_title   = try(each.value.merge_commit_title, var.repository_defaults.merge_commit_title, "PR_TITLE")
  merge_commit_message = try(each.value.merge_commit_message, var.repository_defaults.merge_commit_message, "BLANK")

  vulnerability_alerts = try(each.value.vulnerability_alerts, var.repository_defaults.vulnerability_alerts, true)
  is_template          = try(each.value.is_template, var.repository_defaults.is_template, false)

  license_template = try(each.value.license_template, var.repository_defaults.license_template, null)

  topics = try(each.value.topics, var.repository_defaults.topics, [])

  archived           = try(each.value.archived, var.repository_defaults.archived, false)
  archive_on_destroy = try(each.value.archive_on_destroy, var.repository_defaults.archive_on_destroy, true)

  webhooks          = try(each.value.webhooks, var.repository_defaults.webhooks, {})
  files             = try(each.value.files, var.repository_defaults.files, {})
  labels            = try(each.value.labels, var.repository_defaults.labels, {})
  deploy_keys       = try(each.value.deploy_keys, var.repository_defaults.deploy_keys, {})
  app_installations = try(each.value.app_installations, var.repository_defaults.app_installations, {})

  team_permissions = try(each.value.team_permissions, var.repository_defaults.team_permissions, {})
  user_permissions = try(each.value.user_permissions, var.repository_defaults.user_permissions, {})

  environments = try(each.value.environments, var.repository_defaults.environments, {})
  secrets      = try(each.value.secrets, var.repository_defaults.secrets, {})
  variables    = try(each.value.variables, var.repository_defaults.variables, {})
}
