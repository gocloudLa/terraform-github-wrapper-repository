# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform Repository Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-github-wrapper-repository/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-github-wrapper-repository.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-github-wrapper-repository.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-repository/github"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform wrapper for GitHub Repositories simplifies creation and hardening of repositories at scale. It iterates over a map of repositories and merges shared defaults for visibility, merge policy, branch protection, team access, files, environments, secrets, and variables.


### ✨ Features

- 📦 [Repository Fleet](#repository-fleet) - Create many repositories with shared defaults

- 🛡️ [Branch Protection](#branch-protection) - Protect branches with reviews and status checks

- 📜 [Repository Rulesets](#repository-rulesets) - Define advanced rulesets beyond classic branch protection

- 👥 [Team And User Access](#team-and-user-access) - Grant team and collaborator permissions

- 📄 [Managed Files](#managed-files) - Seed repository files such as Dependabot config

- 🚀 [Environments Secrets And Variables](#environments-secrets-and-variables) - Configure Actions environments with secrets and variables




## 🚀 Quick Start
```hcl
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
    description = "Example private API service"
    topics      = ["example", "api"]
    visibility  = "private"
    files       = {}
    branches    = {}
    team_permissions = {}
    user_permissions = {}
  }
}
```


## 🔧 Additional Features Usage

### Repository Fleet
Uses `for_each` over `repository_parameters` and resolves every attribute through `try(each.value, repository_defaults, hardcoded_default)`, matching the RDS wrapper pattern.


<details><summary>Public module repo</summary>

```hcl
repository_parameters = {
  "terraform-aws-wrapper-example" = {
    description = "Example Terraform wrapper module"
    topics      = ["terraform", "aws"]
  }
}

repository_defaults = {
  visibility         = "public"
  license_template   = "apache-2.0"
  allow_squash_merge = true
  allow_merge_commit = false
  allow_rebase_merge = false
}
```


</details>


### Branch Protection
Configures `github_branch_protection` from `branches.<name>.branch_protection`, including required reviews, status checks, and push allowances.


<details><summary>Protect main</summary>

```hcl
repository_defaults = {
  branches = {
    main = {
      branch_protection = {
        enforce_admins                  = false
        allows_deletions                = false
        allows_force_pushes             = false
        required_status_checks          = ["pull-request-events / workflow-summary"]
        required_status_checks_strict   = true
        required_approving_review_count = 1
        dismiss_stale_reviews           = true
        restrict_pushes = {
          blocks_creations = true
          push_allowances = [
            "example-org/org-admin",
          ]
        }
      }
    }
  }
}
```


</details>


### Repository Rulesets
Creates `github_repository_ruleset` resources from `rulesets`. Team actors can be referenced by slug; the child module resolves slugs to team IDs.


<details><summary>Ruleset skeleton</summary>

```hcl
repository_parameters = {
  "example-api" = {
    rulesets = {
      "default" = {
        name        = "default"
        target      = "branch"
        enforcement = "active"
        conditions = {
          ref_name = {
            include = ["~DEFAULT_BRANCH"]
            exclude = []
          }
        }
        rules = {
          deletion         = true
          non_fast_forward = true
          pull_request = {
            required_approving_review_count = 1
            dismiss_stale_reviews_on_push   = true
          }
        }
      }
    }
  }
}
```


</details>


### Team And User Access
Creates `github_team_repository` and `github_repository_collaborator` bindings from `team_permissions` and `user_permissions` maps.


<details><summary>Default team access</summary>

```hcl
repository_defaults = {
  team_permissions = {
    "module-write"    = "push"
    "module-maintain" = "maintain"
    "org-admin"       = "admin"
  }
}
```


</details>


### Managed Files
Creates `github_repository_file` entries from the `files` map, useful for standardizing CI configuration across module repositories.


<details><summary>Dependabot file</summary>

```hcl
repository_defaults = {
  files = {
    dependabot = {
      branch              = "main"
      file                = ".github/dependabot.yml"
      content             = "version: 2\nupdates: []\n"
      commit_message      = "feat(ci): Add Dependabot configuration."
      commit_author       = "Terraform"
      commit_email        = "terraform@example.com"
      overwrite_on_create = true
    }
  }
}
```


</details>


### Environments Secrets And Variables
Creates repository environments plus repository- and environment-scoped Actions secrets/variables. Team reviewer slugs are resolved to IDs automatically.


<details><summary>Development environment</summary>

```hcl
repository_parameters = {
  "example-api" = {
    environments = {
      development = {
        environment = "development"
        reviewers = {
          teams = ["org-admin"]
        }
        secrets = {
          "AWS_ROLE_ARN" = "arn:aws:iam::123456789012:role/example"
        }
        variables = {
          "ECS_CLUSTER_NAME" = "dmc-lab-example-00"
        }
      }
    }
  }
}
```


</details>




## 📑 Inputs
| Name                        | Description                                                 | Type           | Default    | Required |
| --------------------------- | ----------------------------------------------------------- | -------------- | ---------- | -------- |
| description                 | Repository description                                      | `string`       | `""`       | no       |
| visibility                  | Repository visibility (`public`, `private`, `internal`)     | `string`       | `private`  | no       |
| auto_init                   | Create an initial commit                                    | `bool`         | `true`     | no       |
| default_branch              | Default branch name                                         | `string`       | `main`     | no       |
| branches                    | Map of branches; optional `branch_protection` per branch    | `any`          | `{}`       | no       |
| rulesets                    | Map of repository rulesets                                  | `any`          | `{}`       | no       |
| has_issues                  | Enable Issues                                               | `bool`         | `true`     | no       |
| has_wiki                    | Enable Wiki                                                 | `bool`         | `false`    | no       |
| has_projects                | Enable Projects                                             | `bool`         | `false`    | no       |
| allow_squash_merge          | Allow squash merges                                         | `bool`         | `true`     | no       |
| allow_merge_commit          | Allow merge commits                                         | `bool`         | `true`     | no       |
| allow_rebase_merge          | Allow rebase merges                                         | `bool`         | `true`     | no       |
| delete_branch_on_merge      | Delete head branch after merge                              | `bool`         | `true`     | no       |
| squash_merge_commit_title   | Squash merge commit title policy                            | `string`       | `PR_TITLE` | no       |
| squash_merge_commit_message | Squash merge commit message policy                          | `string`       | `BLANK`    | no       |
| merge_commit_title          | Merge commit title policy                                   | `string`       | `PR_TITLE` | no       |
| merge_commit_message        | Merge commit message policy                                 | `string`       | `BLANK`    | no       |
| vulnerability_alerts        | Enable Dependabot vulnerability alerts                      | `bool`         | `true`     | no       |
| is_template                 | Mark repository as a template                               | `bool`         | `false`    | no       |
| license_template            | License template key (e.g. `apache-2.0`)                    | `string`       | `null`     | no       |
| topics                      | Repository topics                                           | `list(string)` | `[]`       | no       |
| archived                    | Archive the repository                                      | `bool`         | `false`    | no       |
| archive_on_destroy          | Archive instead of delete on destroy                        | `bool`         | `true`     | no       |
| webhooks                    | Map of repository webhooks                                  | `map(object)`  | `{}`       | no       |
| files                       | Map of managed repository files                             | `map(object)`  | `{}`       | no       |
| labels                      | Map of issue labels                                         | `map(object)`  | `{}`       | no       |
| deploy_keys                 | Map of deploy keys                                          | `map(object)`  | `{}`       | no       |
| app_installations           | Map of GitHub App installations for the repository          | `any`          | `{}`       | no       |
| team_permissions            | Map of team slug/id → permission                            | `map(string)`  | `{}`       | no       |
| user_permissions            | Map of username → permission                                | `map(string)`  | `{}`       | no       |
| environments                | Map of Actions environments (reviewers, secrets, variables) | `map(object)`  | `{}`       | no       |
| secrets                     | Map of repository-level Actions secrets                     | `map(string)`  | `{}`       | no       |
| variables                   | Map of repository-level Actions variables                   | `map(string)`  | `{}`       | no       |







## ⚠️ Important Notes
- **ℹ️ Provider Owner:** Configure the GitHub provider `owner` to the target organization (see `examples/complete`).
- **ℹ️ Teams First:** `team_permissions` requires teams that already exist (use the team wrapper first).
- **🔒 Secrets:** Do not commit real Actions secrets; inject plaintext values at apply time or use an external secret store.
- **⚠️ Branch Protection Vs Rulesets:** Prefer one model per repository to avoid overlapping enforcement confusion.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 