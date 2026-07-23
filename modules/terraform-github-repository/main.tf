resource "github_repository" "this" {
  name        = var.name
  description = var.description
  visibility  = var.visibility
  auto_init   = var.auto_init

  # default_branch = var.default_branch

  # Basic features
  has_issues   = var.has_issues
  has_wiki     = var.has_wiki
  has_projects = var.has_projects

  # Merge settings
  allow_squash_merge = var.allow_squash_merge
  allow_merge_commit = var.allow_merge_commit
  allow_rebase_merge = var.allow_rebase_merge

  delete_branch_on_merge = var.delete_branch_on_merge

  squash_merge_commit_title   = var.squash_merge_commit_title
  squash_merge_commit_message = var.squash_merge_commit_message

  merge_commit_title   = var.merge_commit_title
  merge_commit_message = var.merge_commit_message

  # Security
  vulnerability_alerts = var.vulnerability_alerts
  is_template          = var.is_template

  # License
  license_template = var.license_template

  # Topics
  topics = var.topics

  # Archive settings
  archived           = var.archived
  archive_on_destroy = var.archive_on_destroy
}

# Set default branch
resource "github_branch_default" "this" {
  repository = github_repository.this.name
  branch     = var.default_branch
}

# Create additional branches from the default branch
resource "github_branch" "this" {
  for_each = {
    for branch_name, config in var.branches : branch_name => config
    if branch_name != var.default_branch
  }

  repository    = github_repository.this.name
  branch        = each.key
  source_branch = var.default_branch
}

# Github app installations
resource "github_app_installation_repository" "this" {
  for_each        = var.app_installations
  installation_id = each.value.installation_id
  repository      = github_repository.this.name
}

# Branch protection for all configured branches AND default branch
resource "github_branch_protection" "this" {
  for_each = local.branch_protection

  repository_id           = github_repository.this.node_id
  pattern                 = each.key
  enforce_admins          = each.value.enforce_admins
  allows_deletions        = each.value.allows_deletions
  allows_force_pushes     = each.value.allows_force_pushes
  required_linear_history = each.value.required_linear_history

  required_status_checks {
    strict   = each.value.required_status_checks.strict
    contexts = each.value.required_status_checks.contexts
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = each.value.required_pull_request_reviews.dismiss_stale_reviews
    required_approving_review_count = each.value.required_pull_request_reviews.required_approving_review_count
    require_code_owner_reviews      = each.value.required_pull_request_reviews.require_code_owner_reviews
    require_last_push_approval      = each.value.required_pull_request_reviews.require_last_push_approval
    restrict_dismissals             = each.value.required_pull_request_reviews.restrict_dismissals
  }

  dynamic "restrict_pushes" {
    for_each = each.value.restrict_pushes != null ? [1] : []
    content {
      blocks_creations = try(each.value.restrict_pushes.blocks_creations, null)
      push_allowances  = try(each.value.restrict_pushes.push_allowances, [])
    }
  }
}

# Repository Rule Sets
resource "github_repository_ruleset" "this" {
  for_each = local.repository_ruleset

  name        = each.value.name
  repository  = github_repository.this.name
  target      = each.value.target
  enforcement = each.value.enforcement
  depends_on  = [github_app_installation_repository.this]

  conditions {
    ref_name {
      include = each.value.conditions.ref_name.include
      exclude = each.value.conditions.ref_name.exclude
    }
  }

  dynamic "bypass_actors" {
    for_each = each.value.bypass_actors
    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

  dynamic "rules" {
    for_each = each.value.rules != null ? [each.value.rules] : []
    content {
      creation                = try(rules.value.creation, null)
      update                  = try(rules.value.update, null)
      deletion                = try(rules.value.deletion, null)
      non_fast_forward        = try(rules.value.non_fast_forward, null)
      required_linear_history = try(rules.value.required_linear_history, null)
      required_signatures     = try(rules.value.required_signatures, null)

      dynamic "pull_request" {
        for_each = try(rules.value.pull_request, null) != null ? [rules.value.pull_request] : []
        content {
          allowed_merge_methods             = try(pull_request.value.allowed_merge_methods, null)
          required_approving_review_count   = try(pull_request.value.required_approving_review_count, null)
          dismiss_stale_reviews_on_push     = try(pull_request.value.dismiss_stale_reviews_on_push, null)
          require_code_owner_review         = try(pull_request.value.require_code_owner_review, null)
          require_last_push_approval        = try(pull_request.value.require_last_push_approval, null)
          required_review_thread_resolution = try(pull_request.value.required_review_thread_resolution, null)

          dynamic "required_reviewers" {
            for_each = try(pull_request.value.required_reviewers, [])
            content {
              dynamic "reviewer" {
                for_each = required_reviewers.value.reviewer
                content {
                  id   = reviewer.value.id
                  type = reviewer.value.type
                }
              }
              file_patterns     = try(required_reviewers.value.file_patterns, null)
              minimum_approvals = try(required_reviewers.value.minimum_approvals, null)
            }
          }
        }
      }

      dynamic "required_status_checks" {
        for_each = try(rules.value.required_status_checks, null) != null ? [rules.value.required_status_checks] : []
        content {
          strict_required_status_checks_policy = try(required_status_checks.value.strict_required_status_checks_policy, null)
          do_not_enforce_on_create             = try(required_status_checks.value.do_not_enforce_on_create, null)

          dynamic "required_check" {
            for_each = try(
              required_status_checks.value.required_checks,
              try(required_status_checks.value.required_status_checks, [])
            )
            content {
              context        = required_check.value.context
              integration_id = try(required_check.value.integration_id, null)
            }
          }
        }
      }

      dynamic "merge_queue" {
        for_each = try(rules.value.merge_queue, null) != null ? [rules.value.merge_queue] : []
        content {
          merge_method                      = try(merge_queue.value.merge_method, null)
          max_entries_to_build              = try(merge_queue.value.max_entries_to_build, null)
          min_entries_to_merge              = try(merge_queue.value.min_entries_to_merge, null)
          max_entries_to_merge              = try(merge_queue.value.max_entries_to_merge, null)
          min_entries_to_merge_wait_minutes = try(merge_queue.value.min_entries_to_merge_wait_minutes, null)
          grouping_strategy                 = try(merge_queue.value.grouping_strategy, null)
          check_response_timeout_minutes    = try(merge_queue.value.check_response_timeout_minutes, null)
        }
      }

      dynamic "branch_name_pattern" {
        for_each = try(rules.value.branch_name_pattern, null) != null ? [rules.value.branch_name_pattern] : []
        content {
          name     = try(branch_name_pattern.value.name, null)
          negate   = try(branch_name_pattern.value.negate, null)
          operator = try(branch_name_pattern.value.operator, null)
          pattern  = try(branch_name_pattern.value.pattern, null)
        }
      }

      dynamic "tag_name_pattern" {
        for_each = try(rules.value.tag_name_pattern, null) != null ? [rules.value.tag_name_pattern] : []
        content {
          name     = try(tag_name_pattern.value.name, null)
          negate   = try(tag_name_pattern.value.negate, null)
          operator = try(tag_name_pattern.value.operator, null)
          pattern  = try(tag_name_pattern.value.pattern, null)
        }
      }

      dynamic "required_code_scanning" {
        for_each = try(rules.value.required_code_scanning, null) != null ? [rules.value.required_code_scanning] : []
        content {
          dynamic "required_code_scanning_tool" {
            for_each = try(
              required_code_scanning.value.required_code_scanning_tool,
              try(required_code_scanning.value.required_code_scanning_tools, [])
            )
            content {
              alerts_threshold          = try(required_code_scanning_tool.value.alerts_threshold, null)
              security_alerts_threshold = try(required_code_scanning_tool.value.security_alerts_threshold, null)
              tool                      = required_code_scanning_tool.value.tool
            }
          }
        }
      }
    }
  }
}

# Repository webhooks
resource "github_repository_webhook" "this" {
  for_each = var.webhooks

  repository = github_repository.this.name
  events     = each.value.events
  active     = each.value.active
  configuration {
    url          = each.value.configuration.url
    content_type = each.value.configuration.content_type
    secret       = each.value.configuration.secret
    insecure_ssl = each.value.configuration.insecure_ssl
  }
}

# Repository files
resource "github_repository_file" "this" {
  for_each = var.files

  repository          = github_repository.this.name
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commit_message
  commit_author       = each.value.commit_author
  commit_email        = each.value.commit_email
  overwrite_on_create = each.value.overwrite_on_create
}

# Repository labels
resource "github_issue_label" "this" {
  for_each = var.labels

  repository  = github_repository.this.name
  name        = each.value.name
  color       = each.value.color
  description = each.value.description
}

# Repository deploy keys
resource "github_repository_deploy_key" "this" {
  for_each = var.deploy_keys

  title      = each.value.title
  repository = github_repository.this.name
  key        = each.value.key
  read_only  = each.value.read_only
}

# Team permissions
resource "github_team_repository" "this" {
  for_each = var.team_permissions

  team_id    = each.key
  repository = github_repository.this.name
  permission = each.value
}

# User permissions
resource "github_repository_collaborator" "this" {
  for_each = var.user_permissions

  username   = each.key
  repository = github_repository.this.name
  permission = each.value
}

# Repository environments
resource "github_repository_environment" "this" {
  for_each = local.repository_environment

  repository  = github_repository.this.name
  environment = each.value.environment

  dynamic "reviewers" {
    for_each = each.value.reviewers != null ? [1] : []
    content {
      users = each.value.reviewers.users
      teams = each.value.reviewers.teams
    }
  }

  dynamic "deployment_branch_policy" {
    for_each = each.value.deployment_branch_policy != null ? [1] : []
    content {
      protected_branches     = try(each.value.deployment_branch_policy.protected_branches, false)
      custom_branch_policies = try(each.value.deployment_branch_policy.custom_branch_policies, false)
    }
  }

  wait_timer          = each.value.wait_timer
  prevent_self_review = each.value.prevent_self_review
}

# Repository-level secrets
resource "github_actions_secret" "this" {
  for_each = nonsensitive(var.secrets)

  repository      = github_repository.this.name
  secret_name     = each.key
  plaintext_value = each.value
}

# Repository-level variables
resource "github_actions_variable" "this" {
  for_each = var.variables

  repository    = github_repository.this.name
  variable_name = each.key
  value         = each.value
}

# Environment-level secrets
resource "github_actions_environment_secret" "this" {
  for_each = merge([
    for env_key, env_config in var.environments : {
      for secret_key, secret_value in try(env_config.secrets, {}) :
      "${env_key}_${secret_key}" => {
        environment_key = env_key
        environment     = try(env_config.environment, env_key)
        secret_name     = secret_key
        plaintext_value = secret_value
      }
    }
  ]...)

  repository      = github_repository.this.name
  environment     = github_repository_environment.this[each.value.environment_key].environment
  secret_name     = each.value.secret_name
  plaintext_value = each.value.plaintext_value
}

# Environment-level variables
resource "github_actions_environment_variable" "this" {
  for_each = merge([
    for env_key, env_config in var.environments : {
      for var_key, var_value in try(env_config.variables, {}) :
      "${env_key}_${var_key}" => {
        environment_key = env_key
        environment     = try(env_config.environment, env_key)
        variable_name   = var_key
        value           = var_value
      }
    }
  ]...)

  repository    = github_repository.this.name
  environment   = github_repository_environment.this[each.value.environment_key].environment
  variable_name = each.value.variable_name
  value         = each.value.value
}
