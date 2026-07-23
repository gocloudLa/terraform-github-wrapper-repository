locals {
  org_teams_by_slug = {
    for t in try(data.github_organization_teams.all.teams, []) :
    t.slug => t.id
  }

  # One entry per branch that defines branch_protection.
  branch_protection_tmp = [
    for branch_name, config in var.branches :
    {
      "${branch_name}" = {
        enforce_admins          = try(config.branch_protection.enforce_admins, false)
        allows_deletions        = try(config.branch_protection.allows_deletions, false)
        allows_force_pushes     = try(config.branch_protection.allows_force_pushes, false)
        required_linear_history = try(config.branch_protection.required_linear_history, false)
        required_status_checks = {
          strict   = try(config.branch_protection.required_status_checks_strict, false)
          contexts = try(config.branch_protection.required_status_checks, [])
        }
        required_pull_request_reviews = {
          dismiss_stale_reviews           = try(config.branch_protection.dismiss_stale_reviews, true)
          required_approving_review_count = try(config.branch_protection.required_approving_review_count, 1)
          require_code_owner_reviews      = try(config.branch_protection.require_code_owner_reviews, false)
          require_last_push_approval      = try(config.branch_protection.require_last_push_approval, false)
          restrict_dismissals             = try(config.branch_protection.restrict_dismissals, false)
        }
        restrict_pushes = try(config.branch_protection.restrict_pushes, null)
      }
    }
    if try(config.branch_protection, null) != null
  ]
  branch_protection = merge(flatten(local.branch_protection_tmp)...)

  # One entry per ruleset in var.rulesets.
  repository_ruleset_tmp = [
    for key, ruleset in var.rulesets :
    {
      "${key}" = {
        name        = try(ruleset.name, key)
        target      = try(ruleset.target, "branch")
        enforcement = try(ruleset.enforcement, "active")
        conditions = {
          ref_name = {
            include = try(ruleset.conditions.ref_name.include, ["~ALL"])
            exclude = try(ruleset.conditions.ref_name.exclude, [])
          }
        }
        bypass_actors = [
          for actor in try(ruleset.bypass_actors, []) : {
            actor_id    = try(actor.actor_type, "") == "Team" && !can(tonumber(actor.actor_id)) ? local.org_teams_by_slug[tostring(actor.actor_id)] : actor.actor_id
            actor_type  = actor.actor_type
            bypass_mode = try(actor.bypass_mode, "always")
          }
        ]
        rules = merge(ruleset.rules, {
          pull_request = try(ruleset.rules.pull_request, null) != null ? merge(ruleset.rules.pull_request, {
            required_reviewers = [
              for rr in try(ruleset.rules.pull_request.required_reviewers, []) : {
                reviewer = [
                  for rev in flatten([try(rr.reviewer, [])]) : {
                    id   = try(rev.type, "") == "Team" && !can(tonumber(try(rev.id, ""))) ? local.org_teams_by_slug[tostring(try(rev.id, ""))] : try(rev.id, null)
                    type = try(rev.type, "User")
                  }
                ]
                file_patterns     = try(rr.file_patterns, null)
                minimum_approvals = try(rr.minimum_approvals, null)
              }
            ]
          }) : null
        })
      }
    }
  ]
  repository_ruleset = merge(flatten(local.repository_ruleset_tmp)...)

  # One entry per environment in var.environments.
  repository_environment_tmp = [
    for env_key, env in var.environments :
    {
      "${env_key}" = {
        environment = try(env.environment, env_key)
        reviewers = try(env.reviewers, null) != null ? {
          users = try(env.reviewers.users, [])
          teams = [
            for team in try(env.reviewers.teams, []) :
            can(tonumber(team)) ? team : local.org_teams_by_slug[team]
          ]
        } : null
        deployment_branch_policy = try(env.deployment_branch_policy, null)
        wait_timer               = try(env.wait_timer, null)
        prevent_self_review      = try(env.prevent_self_review, null)
      }
    }
  ]
  repository_environment = merge(flatten(local.repository_environment_tmp)...)
}
