# GitHub Repository Terraform Module

A comprehensive Terraform module for managing GitHub repositories with advanced features including branch protection, security settings, webhooks, environments, and more.

## Features

- **Complete Repository Management**: Create and configure GitHub repositories with all available settings
- **Branch Protection**: Advanced branch protection rules with status checks, PR reviews, and push restrictions
- **Rulesets**: Branch rulesets with bypass actors and required reviewers (provider >= 6.11 for required reviewers)
- **Security & Analysis**: Configure vulnerability alerts and security settings
- **Collaboration**: Manage team permissions and user collaborators
- **CI/CD Integration**: Repository-level and environment-level secrets and variables
- **Environments**: Configure deployment environments with reviewers, wait timers, and branch policies
- **Webhooks**: Configure repository webhooks for external integrations
- **Content Management**: Create files and labels in the repository
- **Deploy Keys**: Manage SSH deploy keys for automated deployments

## Usage

### Basic Repository

```hcl
module "github_repository" {
  source = "./modules/github/repository"

  name        = "my-awesome-project"
  description = "A comprehensive project with advanced features"
  visibility  = "private"
  
  auto_init = true
  topics    = ["terraform", "github", "automation"]
}
```

### Advanced Repository with Branch Protection

```hcl
module "github_repository" {
  source = "./modules/github/repository"

  name        = "production-app"
  description = "Production application repository"
  visibility  = "private"
  
  # Repository settings
  auto_init             = true
  delete_branch_on_merge = true
  allow_squash_merge    = true
  allow_merge_commit    = false
  allow_rebase_merge    = true
  
  # Security settings
  vulnerability_alerts = true
  
  # Branch protection
  branches = {
    main = {
      branch_protection = {
        enforce_admins                  = true
        allows_deletions                = false
        allows_force_pushes             = false
        required_status_checks          = ["ci/build", "ci/test"]
        required_status_checks_strict   = true
        required_approving_review_count = 2
        require_code_owner_reviews      = true
        restrict_pushes = {
          blocks_creations = true
          push_allowances  = ["team-slug"]
        }
      }
    }
  }
  
  # User permissions (collaborators)
  user_permissions = {
    "developer1" = "push"
    "reviewer1"  = "pull"
  }
  
  # Repository-level secrets
  secrets = {
    DATABASE_URL = "postgresql://user:pass@localhost/db"
    API_KEY      = "secret-api-key"
  }
  
  # Repository-level variables
  variables = {
    ENVIRONMENT = "production"
    REGION      = "us-west-2"
  }
  
  # Webhooks
  webhooks = {
    slack_notifications = {
      name   = "slack-notifications"
      events = ["push", "pull_request", "issues"]
      active = true
      configuration = {
        url          = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
        content_type = "json"
        secret       = "webhook-secret"
        insecure_ssl = false
      }
    }
  }
  
  # Environments with secrets and variables
  environments = {
    production = {
      environment = "production"
      wait_timer  = 5
      prevent_self_review = true
      reviewers = {
        users = ["admin1", "admin2"]
        teams = ["production-team"]
      }
      deployment_branch_policy = {
        protected_branches     = true
        custom_branch_policies = false
      }
      secrets = {
        PROD_API_KEY     = "production-secret-key"
        PROD_DB_PASSWORD = "super-secure-password"
      }
      variables = {
        PROD_REGION = "us-west-2"
        PROD_ENV    = "production"
      }
    }
    staging = {
      environment = "staging"
      wait_timer  = 0
      reviewers = {
        users = ["dev-lead"]
        teams = ["dev-team"]
      }
      secrets = {
        STAGING_API_KEY = "staging-secret-key"
      }
      variables = {
        STAGING_REGION = "us-east-1"
      }
    }
  }
  
  # Repository files
  files = {
    readme = {
      branch         = "main"
      file           = "README.md"
      content        = "# My Awesome Project\n\nThis is a comprehensive project managed with Terraform."
      commit_message = "Add README.md"
      commit_author  = "Terraform"
      commit_email   = "terraform@example.com"
    }
    gitignore = {
      branch         = "main"
      file           = ".gitignore"
      content        = "*.log\n.env\nnode_modules/\n.DS_Store"
      commit_message = "Add .gitignore"
      commit_author  = "Terraform"
      commit_email   = "terraform@example.com"
    }
  }
  
  # Labels
  labels = {
    bug = {
      name        = "bug"
      color       = "d73a4a"
      description = "Something isn't working"
    }
    enhancement = {
      name        = "enhancement"
      color       = "a2eeef"
      description = "New feature or request"
    }
    documentation = {
      name        = "documentation"
      color       = "0075ca"
      description = "Improvements or additions to documentation"
    }
  }
  
  # Team permissions (teams must exist in the organization)
  team_permissions = {
    "team-slug-1" = "push"
    "team-slug-2" = "pull"
  }
}
```

### Rulesets with Required Reviewers

Team reviewers and bypass actors accept team slugs and are resolved to IDs automatically.

```hcl
module "github_repository" {
  source = "./modules/github/repository"

  name        = "ruleset-example"
  description = "Repository with ruleset reviewers"
  visibility  = "private"

  branches = {
    main = {
      ruleset = {
        name        = "protected-main"
        target      = "branch"
        enforcement = "active"
        conditions = {
          ref_name = {
            include = ["refs/heads/main"]
            exclude = []
          }
        }
        bypass_actors = [
          {
            actor_id   = "platform-team"
            actor_type = "Team"
            bypass_mode = "always"
          }
        ]
        rules = {
          pull_request = {
            required_approving_review_count = 2
            required_reviewers = [
              {
                reviewer = [
                  {
                    id   = "security-team"
                    type = "Team"
                  }
                ]
                file_patterns     = ["**/*"]
                minimum_approvals = 1
              }
            ]
          }
        }
      }
    }
  }
}
```

### Template Repository

```hcl
module "github_repository" {
  source = "./modules/github/repository"

  name        = "project-template"
  description = "Template repository for new projects"
  visibility  = "public"
  is_template = true
}
```

### Repository with Environments, Secrets, and Variables

```hcl
module "github_repository" {
  source = "./modules/github/repository"

  name        = "production-app"
  description = "Production application with CI/CD"
  visibility  = "private"
  
  # Repository-level secrets (available to all workflows)
  secrets = {
    SHARED_DB_URL = "postgresql://shared-db:5432/app"
    SLACK_WEBHOOK = "https://hooks.slack.com/services/..."
  }
  
  # Repository-level variables (available to all workflows)
  variables = {
    DEFAULT_REGION = "us-west-2"
    APP_VERSION    = "1.0.0"
  }
  
  # Environments with environment-specific secrets and variables
  environments = {
    production = {
      environment = "production"
      wait_timer  = 10  # Wait 10 minutes before allowing deployment
      prevent_self_review = true
      
      # Required reviewers for production deployments
      reviewers = {
        users = ["admin1", "admin2"]
        teams = ["production-team"]
      }
      
      # Only protected branches can deploy to production
      deployment_branch_policy = {
        protected_branches     = true
        custom_branch_policies = false
      }
      
      # Production-specific secrets
      secrets = {
        PROD_API_KEY     = "prod-secret-key-12345"
        PROD_DB_PASSWORD = "super-secure-production-password"
      }
      
      # Production-specific variables
      variables = {
        PROD_REGION = "us-west-2"
        PROD_ENV    = "production"
      }
    }
    
    staging = {
      environment = "staging"
      wait_timer  = 0  # No wait timer for staging
      
      # Staging reviewers
      reviewers = {
        users = ["dev-lead"]
        teams = ["dev-team"]
      }
      
      # Staging-specific secrets
      secrets = {
        STAGING_API_KEY = "staging-secret-key"
      }
      
      # Staging-specific variables
      variables = {
        STAGING_REGION = "us-east-1"
        STAGING_ENV    = "staging"
      }
    }
    
    development = {
      environment = "development"
      # No wait timer, no reviewers for development
      # Development-specific variables only
      variables = {
        DEV_REGION = "us-east-1"
      }
    }
  }
}
```

### Simple Repository with Only Secrets and Variables

```hcl
module "github_repository" {
  source = "./modules/github/repository"

  name        = "simple-app"
  description = "Simple application"
  visibility  = "private"
  
  # Repository-level secrets
  secrets = {
    DATABASE_URL = "postgresql://localhost:5432/mydb"
    API_TOKEN    = "my-api-token"
  }
  
  # Repository-level variables
  variables = {
    ENVIRONMENT = "development"
    REGION      = "us-west-2"
  }
}
```

### Complete CI/CD Example with Multiple Environments

This example shows a production-ready setup with multiple environments, each with their own secrets and variables:

```hcl
module "github_repository" {
  source = "./modules/github/repository"

  name        = "production-api"
  description = "Production API with full CI/CD setup"
  visibility  = "private"
  
  # Repository-level secrets (shared across all environments)
  secrets = {
    DOCKER_REGISTRY_URL = "registry.example.com"
    SLACK_WEBHOOK       = "https://hooks.slack.com/services/..."
  }
  
  # Repository-level variables (shared across all environments)
  variables = {
    DOCKER_IMAGE_PREFIX = "mycompany/api"
    DEFAULT_TIMEOUT     = "300"
  }
  
  # Multiple environments with different configurations
  environments = {
    # Production environment with strict controls
    production = {
      environment = "production"
      wait_timer  = 15  # 15 minute wait before deployment
      prevent_self_review = true
      
      # Required reviewers for production
      reviewers = {
        users = ["senior-dev", "tech-lead"]
        teams = ["production-team", "security-team"]
      }
      
      # Only protected branches can deploy to production
      deployment_branch_policy = {
        protected_branches     = true
        custom_branch_policies = false
      }
      
      # Production-specific secrets
      secrets = {
        PROD_DB_CONNECTION  = "postgresql://prod-db:5432/production"
        PROD_API_KEY        = "prod-secret-key-xyz123"
        PROD_AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE"
      }
      
      # Production-specific variables
      variables = {
        PROD_REGION   = "us-west-2"
        PROD_ENV      = "production"
        PROD_REPLICAS = "5"
      }
    }
    
    # Staging environment with moderate controls
    staging = {
      environment = "staging"
      wait_timer  = 5  # 5 minute wait
      
      reviewers = {
        users = ["dev-lead"]
        teams = ["dev-team"]
      }
      
      secrets = {
        STAGING_DB_CONNECTION = "postgresql://staging-db:5432/staging"
        STAGING_API_KEY       = "staging-secret-key"
      }
      
      variables = {
        STAGING_REGION   = "us-east-1"
        STAGING_ENV      = "staging"
        STAGING_REPLICAS = "2"
      }
    }
    
    # Development environment with minimal controls
    development = {
      environment = "development"
      wait_timer  = 0  # No wait timer
      
      # No reviewers required for development
      # No deployment branch policy restrictions
      
      secrets = {
        DEV_DB_CONNECTION = "postgresql://localhost:5432/dev"
      }
      
      variables = {
        DEV_REGION = "us-east-1"
        DEV_ENV    = "development"
      }
    }
  }
}
```

### Using Environments in GitHub Actions Workflows

Once you've configured environments, secrets, and variables, you can use them in your GitHub Actions workflows:

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production  # This will use the production environment
    
    steps:
      - name: Use repository secret
        run: |
          echo "Using ${{ secrets.DOCKER_REGISTRY_URL }}"
      
      - name: Use repository variable
        run: |
          echo "Image: ${{ vars.DOCKER_IMAGE_PREFIX }}:latest"
      
      - name: Use environment secret
        run: |
          echo "DB: ${{ secrets.PROD_DB_CONNECTION }}"
      
      - name: Use environment variable
        run: |
          echo "Region: ${{ vars.PROD_REGION }}"
          echo "Replicas: ${{ vars.PROD_REPLICAS }}"
```

**Note**: The `wait_timer` and `reviewers` configured in the environment will be enforced by GitHub when deploying to that environment.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| github | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| github | ~> 6.0 |

## Inputs

### Repository Basic Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the repository | `string` | n/a | yes |
| description | A description of the repository | `string` | `null` | no |
| visibility | Can be public or private. If your organization is associated with an enterprise account using GitHub Enterprise Cloud (GHEC), you can also choose internal | `string` | `"private"` | no |

### Branch Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| default_branch | The default branch name | `string` | `"main"` | no |
| branches | Map of branches with optional `branch_protection` and `ruleset` configuration (including required reviewers) | `map(any)` | `{}` | no |

### Repository Features

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| auto_init | Set to true to produce an initial commit in the repository | `bool` | `false` | no |
| has_issues | Set to true to enable the GitHub Issues features on the repository | `bool` | `true` | no |
| has_wiki | Set to true to enable the GitHub Wiki features on the repository | `bool` | `false` | no |
| has_projects | Set to true to enable the GitHub Projects features on the repository | `bool` | `false` | no |

### Merge Settings

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allow_squash_merge | Set to false to disable squash merges on the repository | `bool` | `true` | no |
| allow_merge_commit | Set to false to disable merge commits on the repository | `bool` | `true` | no |
| allow_rebase_merge | Set to false to disable rebase merges on the repository | `bool` | `true` | no |
| delete_branch_on_merge | Automatically delete head branch after a pull request is merged | `bool` | `true` | no |
| squash_merge_commit_title | Can be PR_TITLE or COMMIT_OR_PR_TITLE for a default squash merge commit title | `string` | `"PR_TITLE"` | no |
| squash_merge_commit_message | Can be PR_BODY, COMMIT_MESSAGES, or BLANK for a default squash merge commit message | `string` | `"BLANK"` | no |

### Security and Analysis

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vulnerability_alerts | Set to true to enable security alerts for vulnerable dependencies | `bool` | `true` | no |
| is_template | Set to true to tell GitHub that this is a template repository | `bool` | `false` | no |
| license_template | Use the name of the template without the extension. For example, 'mit' or 'mpl-2.0' | `string` | `null` | no |
| topics | The list of topics of the repository | `list(string)` | `[]` | no |
| archived | Specifies if the repository should be archived | `bool` | `false` | no |
| archive_on_destroy | Set to true to archive the repository instead of deleting on destroy | `bool` | `true` | no |

### Advanced Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| branches | Map of branches with optional `branch_protection` and `ruleset` configuration (including required reviewers) | `map(any)` | `{}` | no |
| team_permissions | Map of team permissions. Key is team_id, value is permission | `map(string)` | `{}` | no |
| user_permissions | Map of user permissions. Key is username, value is permission | `map(string)` | `{}` | no |
| webhooks | Map of webhooks | `map(object)` | `{}` | no |
| deploy_keys | Map of deploy keys | `map(object)` | `{}` | no |
| files | Map of files to create in the repository | `map(object)` | `{}` | no |
| labels | Map of issue labels | `map(object)` | `{}` | no |

### CI/CD Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environments | Map of repository environments with their configuration | `map(object)` | `{}` | no |
| secrets | Map of repository-level GitHub Actions secrets | `map(object)` | `{}` | no |
| variables | Map of repository-level GitHub Actions variables | `map(object)` | `{}` | no |

#### Environment Object Structure

Each environment in the `environments` map supports the following attributes:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Name of the environment (defaults to map key if not specified) | `string` | `null` | no |
| wait_timer | Amount of time to wait before allowing deployments (in minutes) | `number` | `null` | no |
| prevent_self_review | Prevent admins and bypassers from reviewing their own deployments | `bool` | `null` | no |
| reviewers | Object containing users and teams that can review deployments | `object` | `null` | no |
| reviewers.users | List of GitHub usernames that can review deployments | `list(string)` | `[]` | no |
| reviewers.teams | List of team slugs or IDs that can review deployments | `list(string)` | `[]` | no |
| deployment_branch_policy | Object defining branch deployment policies | `object` | `null` | no |
| deployment_branch_policy.protected_branches | Only protected branches can deploy | `bool` | `false` | no |
| deployment_branch_policy.custom_branch_policies | Custom branch policies can be defined | `bool` | `false` | no |
| secrets | Map of environment-specific secrets. Key is secret name, value is secret value | `map(string)` | `{}` | no |
| variables | Map of environment-specific variables. Key is variable name, value is variable value | `map(string)` | `{}` | no |

#### Secret Format

Secrets use a simple key-value format where the key is the secret name and the value is the secret value:

```hcl
secrets = {
  "SECRET_NAME" = "secret-value"
  "API_KEY"     = "my-api-key-123"
}
```

#### Variable Format

Variables use a simple key-value format where the key is the variable name and the value is the variable value:

```hcl
variables = {
  "VARIABLE_NAME" = "variable-value"
  "AWS_REGION"    = "us-west-2"
}
```

**Note**: Repository-level `secrets` are marked as `sensitive` to prevent their values from appearing in Terraform logs.

## Outputs

| Name | Description |
|------|-------------|
| repository_id | The ID of the repository |
| repository_name | The name of the repository |
| repository_full_name | The full name of the repository |
| repository_html_url | The URL to view the repository on GitHub |
| repository_ssh_url | The SSH URL to clone the repository |
| repository_https_url | The HTTPS URL to clone the repository |
| repository_description | The description of the repository |
| repository_visibility | The visibility of the repository |
| repository_topics | The topics of the repository |
| repository_archived | Whether the repository is archived |
| repository_default_branch | The default branch of the repository |
| branch_protection | Map of branch protection rules |
| webhooks | Map of webhooks |
| files | Map of files created in the repository |
| labels | Map of issue labels |
| deploy_keys | Map of deploy keys configured |
| environments | Map of environments configured (sensitive) |
| secrets | Map of repository-level secrets (sensitive) |
| variables | Map of repository-level variables |
| environment_secrets | Map of environment-level secrets (sensitive) |
| environment_variables | Map of environment-level variables |

## Examples

This README includes several complete examples:

- **Basic Repository**: Simple repository creation
- **Advanced Repository with Branch Protection**: Repository with branch protection rules
- **Repository with Environments, Secrets, and Variables**: Complete CI/CD setup with environments
- **Simple Repository with Only Secrets and Variables**: Basic secrets and variables configuration
- **Template Repository**: Creating a template repository

For more examples, see the `example/complete/` directory in the root of this module.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository or contact the maintainers. 
