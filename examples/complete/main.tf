module "wrapper_repository" {
  source = "../../"

  metadata = local.metadata

  repository_parameters = {
    ".github" = {
      description = "Organization profile and shared GitHub Actions workflows"
      topics      = ["github", "cicd", "home"]
      files       = {}
      team_permissions = {
        "module-write"    = "push"
        "module-maintain" = "push"
        "org-admin"       = "admin"
      }
    }

    "example-web" = {
      description = "Example public website application"
      topics      = ["example", "website"]
      # Default: public (from repository_defaults)
      visibility = "private"
      files      = {}
      branches   = {}
      # Override defaults for this repo
      team_permissions = {}
      user_permissions = {}
    }

    "example-api" = {
      description      = "Example private API service"
      topics           = ["example", "api"]
      visibility       = "private"
      files            = {}
      branches         = {}
      team_permissions = {}
      user_permissions = {}

      # environments = {
      #   development = {
      #     environment = "development"
      #     # wait_timer          = 5
      #     # prevent_self_review = true
      #     # reviewers = {
      #     #   users = ["admin1-example"]
      #     #   teams = ["org-admin"]
      #     # }
      #     # deployment_branch_policy = {
      #     #   protected_branches     = true
      #     #   custom_branch_policies = false
      #     # }
      #     secrets = {
      #       "AWS_ROLE_ARN" = "arn:aws:iam::123456789012:role/example"
      #     }
      #     variables = {
      #       "ECS_CLUSTER_NAME" = "dmc-lab-example-00"
      #     }
      #   }
      # }
    }
  }

  repository_defaults = {
    visibility   = "public"
    has_issues   = true
    has_wiki     = false
    has_projects = false

    # Default: true / true / true
    allow_squash_merge = true
    allow_merge_commit = false
    allow_rebase_merge = false

    delete_branch_on_merge = true

    merge_commit_message = "PR_TITLE"
    merge_commit_title   = "MERGE_MESSAGE"

    vulnerability_alerts = true
    is_template          = false

    license_template = "apache-2.0"
    default_branch   = "main"

    branches = {
      main = {
        branch_protection = {
          enforce_admins                  = false
          allows_deletions                = false
          allows_force_pushes             = false
          required_status_checks          = ["pull-request-events / workflow-summary"]
          required_status_checks_strict   = true
          required_approving_review_count = 1
          require_code_owner_reviews      = false
          dismiss_stale_reviews           = true
          require_last_push_approval      = false
          restrict_dismissals             = false
          restrict_pushes = {
            blocks_creations = true
            push_allowances = [
              "example-org/org-admin",
            ]
          }
        }
      }
    }

    team_permissions = {
      "module-write"    = "push"
      "module-maintain" = "maintain"
      "org-admin"       = "admin"
    }

    user_permissions = {}

    files = {
      dependabot = {
        branch              = "main"
        file                = ".github/dependabot.yml"
        content             = <<-EOT
          version: 2
          updates:
            - package-ecosystem: "terraform"
              directories:
                - "/"
                - "/examples/*/"
                - "/modules/*/*/"
              schedule:
                interval: "weekly"
              open-pull-requests-limit: 20
              assignees:
                - "admin1-example"
              reviewers:
                - "user1-example"
              groups:
                all-terraform-dependencies:
                  patterns:
                    - "*"
        EOT
        commit_message      = "feat(ci): Add Dependabot configuration."
        commit_author       = "Terraform"
        commit_email        = "terraform@example.com"
        overwrite_on_create = true
      }
    }
  }
}
