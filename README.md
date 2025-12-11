---
post_title: "GitHub Enterprise Repositories Terraform Module"
author1: "FKoster"
post_slug: "github-enterprise-repositories-terraform-module"
microsoft_alias: "fkoster"
featured_image: ""
categories: ["devops"]
tags: ["terraform", "github", "enterprise", "repositories", "iac"]
ai_note: "Assisted by GitHub Copilot."
summary: "Comprehensive Terraform module to create and manage GitHub Enterprise repositories with branch protection, team access, secrets, and security settings."
post_date: "2025-12-11"
---

## Overview

Terraform module to create and manage GitHub Enterprise repositories with comprehensive support for:

- Repository configuration and settings
- Branch protection rules
- Team and collaborator access
- Deploy keys and webhooks
- Actions secrets and variables (repository and organization level)
- Security and analysis features
- GitHub Pages configuration

## Features

- **Complete Repository Management**: Create and configure repositories with all available settings
- **Branch Protection**: Implement comprehensive branch protection rules including required reviews, status checks, and restrictions
- **Access Control**: Manage team and individual collaborator access with granular permissions
- **CI/CD Integration**: Configure deploy keys, webhooks, secrets, and variables for automated workflows
- **Security**: Enable vulnerability alerts, advanced security features, secret scanning, and push protection
- **GitHub Pages**: Configure static site hosting directly from repositories
- **Organization-Level Resources**: Manage organization secrets and variables shared across repositories

## Prerequisites

- Terraform 1.6+ and GitHub provider `integrations/github` 6.0.0+
- GitHub Enterprise organization
- GitHub Personal Access Token (PAT) or GitHub App credentials with appropriate permissions:
  - `repo` (full control of repositories)
  - `admin:org` (read and write access to organization)
  - `delete_repo` (if repository deletion is needed)

> [!NOTE]
> For GitHub Enterprise Managed Users (EMU), ensure your token is SSO authorized for the organization.

## Quickstart

1. Export credentials (PAT example):
   ```bash
   export GITHUB_TOKEN=ghp_your_token
   ```
2. Create a `main.tf` file with your configuration:

   ```hcl
   provider "github" {
     owner = "my-org"
   }

   module "repositories" {
     source = "path/to/module"

     repositories = {
       my-app = {
         description = "My application"
         visibility  = "private"
         topics      = ["terraform", "github"]
       }
     }
   }
   ```

3. Run:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Usage Examples

### Basic Repository

```hcl
module "basic_repos" {
  source = "path/to/module"

  repositories = {
    my-app = {
      description = "My application repository"
      visibility  = "private"

      has_issues   = true
      has_wiki     = false
      has_projects = false

      topics = ["terraform", "github"]

      delete_branch_on_merge = true
      auto_init              = true
      gitignore_template     = "Terraform"
      license_template       = "mit"
    }
  }
}
```

### Production Repository with Branch Protection

```hcl
module "production_repos" {
  source = "path/to/module"

  repositories = {
    production-app = {
      description = "Production application"
      visibility  = "private"

      # Merge settings
      allow_merge_commit     = false
      allow_squash_merge     = true
      allow_rebase_merge     = false
      delete_branch_on_merge = true

      # Branch protection
      branch_protection = {
        pattern        = "main"
        enforce_admins = true

        required_status_checks = {
          strict   = true
          contexts = ["ci/build", "ci/test", "security/scan"]
        }

        required_pull_request_reviews = {
          dismiss_stale_reviews           = true
          require_code_owner_reviews      = true
          required_approving_review_count = 2
          require_last_push_approval      = true
        }

        require_signed_commits          = true
        required_linear_history         = true
        require_conversation_resolution = true
      }

      # Security
      vulnerability_alerts = true
      security_and_analysis = {
        advanced_security = {
          status = "enabled"
        }
        secret_scanning = {
          status = "enabled"
        }
        secret_scanning_push_protection = {
          status = "enabled"
        }
      }
    }
  }
}
```

### Repository with Team Access and Secrets

```hcl
module "team_repos" {
  source = "path/to/module"

  repositories = {
    shared-platform = {
      description = "Shared platform repository"
      visibility  = "private"

      # Team access
      teams = {
        "platform-team" = {
          permission = "admin"
        }
        "dev-team" = {
          permission = "push"
        }
        "qa-team" = {
          permission = "pull"
        }
      }

      # Collaborators
      collaborators = {
        "external-consultant" = {
          permission = "triage"
        }
      }

      # Repository secrets
      secrets = {
        "API_KEY" = {
          plaintext_value = var.api_key
        }
      }

      # Repository variables
      variables = {
        "ENVIRONMENT" = {
          value = "production"
        }
      }
    }
  }

  # Organization-level secrets
  organization_secrets = {
    "ORG_DOCKER_TOKEN" = {
      plaintext_value = var.docker_token
      visibility      = "private"
    }
  }
}
```

### Repository with Webhooks and Deploy Keys

```hcl
module "cicd_repos" {
  source = "path/to/module"

  repositories = {
    automated-app = {
      description = "Application with CI/CD"
      visibility  = "private"

      # Deploy keys
      deploy_keys = {
        "ci-cd-deploy" = {
          key       = var.deploy_key
          read_only = false
        }
      }

      # Webhooks
      webhooks = {
        "ci-pipeline" = {
          url          = "https://ci.example.com/webhook"
          content_type = "json"
          secret       = var.webhook_secret
          events       = ["push", "pull_request", "release"]
          active       = true
        }
        "slack-notifications" = {
          url          = "https://hooks.slack.com/services/xxx"
          content_type = "json"
          events       = ["push", "issues", "pull_request"]
          active       = true
        }
      }
    }
  }
}
```

### Documentation Repository with GitHub Pages

```hcl
module "docs_repos" {
  source = "path/to/module"

  repositories = {
    documentation = {
      description = "Project documentation"
      visibility  = "public"

      has_wiki = true

      topics = ["documentation"]

      # GitHub Pages
      pages = {
        source = {
          branch = "main"
          path   = "/docs"
        }
        cname = "docs.example.com"
      }

      auto_init          = true
      gitignore_template = "Jekyll"
      license_template   = "cc-by-4.0"
    }
  }
}
```

## Module Inputs

- `teams` (map):
  - `name` (string) – team display name
  - `description` (string, optional)
  - `privacy` (string, default `closed`, allowed `closed` or `secret`)
  - `parent_team_id` (string, optional)
  - `idp_group_names` (list[string]) – EMU external group names to map

## Module Outputs

- `external_groups` – all EMU external groups discovered
- `teams` – ids, slugs, and node_ids per team key
- `group_mappings` – created EMU mappings (group_id, team_slug, etag)

## Usage

Minimal example with IdP group name lookup:

```hcl
provider "github" {
  owner = var.owner
}

module "emu_teams" {
  source = "../../"

  teams = {
    platform = {
      name            = "Platform"
      description     = "Shared platform engineering team"
      privacy         = "closed"
      idp_group_names = [
        "ghe-cloudregie-admins",
      ]
    }

    data = {
      name            = "Data"
      description     = "Data engineering team"
      privacy         = "closed"
      idp_group_names = [
        "ghe-data-engineers",
      ]
    }
  }
}
```

## Validation Behavior

- The module fails during planning if any `idp_group_names` are missing from EMU external groups and prints the missing names.

## Project Layout

## Best Practices

### Security

1. **Enable vulnerability alerts** for all repositories
2. **Use branch protection** on main branches with required reviews
3. **Enable secret scanning** and push protection for sensitive repositories
4. **Store secrets securely** using GitHub Actions secrets, not in code
5. **Require signed commits** for production repositories
6. **Use least-privilege access** - grant minimum required permissions

### Branch Protection

1. **Require pull request reviews** for production branches
2. **Enable status checks** to ensure CI passes before merge
3. **Require conversation resolution** to ensure all feedback is addressed
4. **Use linear history** to maintain clean commit history
5. **Don't bypass rules for admins** on critical repositories

### Team Access

1. **Use team-based access** instead of individual collaborators where possible
2. **Follow principle of least privilege** - start with "pull" and increase as needed
3. **Use "maintain"** for team leads who need repository management but not full admin
4. **Reserve "admin"** for repository owners and platform teams

### Merge Strategy

1. **Disable merge commits** for cleaner history (use squash or rebase)
2. **Enable delete branch on merge** to keep repositories clean
3. **Use squash merge** with PR title for better commit messages
4. **Require linear history** to prevent complex merge graphs

### Repository Hygiene

1. **Use descriptive names and descriptions**
2. **Add relevant topics** for discoverability
3. **Include a license** for open source repositories
4. **Use gitignore templates** appropriate for your technology
5. **Archive old repositories** instead of deleting them

### CI/CD

1. **Use organization secrets** for credentials shared across repositories
2. **Rotate deploy keys** regularly
3. **Secure webhooks** with secrets
4. **Use read-only deploy keys** unless write access is required
5. **Limit secret visibility** to only repositories that need them

## Troubleshooting

### Permission Errors

If you encounter permission errors:

1. Verify your token has `repo` and `admin:org` scopes
2. For EMU organizations, ensure SSO authorization
3. Check organization settings don't restrict repository creation

### Branch Protection Not Applied

If branch protection isn't working:

1. Ensure the branch exists before applying protection
2. Verify `create_default_branch_protection` is set to `true`
3. Check that status check contexts match your CI/CD configuration

### Team Access Issues

If teams can't access repositories:

1. Verify team slugs are correct (not display names)
2. Ensure teams exist in the organization
3. Check organization base permissions don't override team settings

## Examples

See the [examples](./examples) directory for complete working examples:

- [basic](./examples/basic) - Simple repository creation
- [advanced](./examples/advanced) - Production-ready configuration with all features

## Project Structure

```
.
├── README.md                  # This file
├── main.tf                    # Main module logic
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── versions.tf                # Terraform and provider versions
└── examples/
    ├── basic/                 # Basic usage example
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    └── advanced/              # Advanced usage example
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## References

- [GitHub Provider Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [GitHub REST API Documentation](https://docs.github.com/en/rest)
- [GitHub Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 6.8.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 6.8.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_actions_organization_secret.this](https://registry.terraform.io/providers/integrations/github/6.8.3/docs/resources/actions_organization_secret) | resource |
| [github_actions_organization_variable.this](https://registry.terraform.io/providers/integrations/github/6.8.3/docs/resources/actions_organization_variable) | resource |
| [github_actions_secret.this](https://registry.terraform.io/providers/integrations/github/6.8.3/docs/resources/actions_secret) | resource |
| [github_actions_variable.this](https://registry.terraform.io/providers/integrations/github/6.8.3/docs/resources/actions_variable) | resource |
| [github_branch_protection.this](https://registry.terraform.io/providers/integrations/github/6.8.3/docs/resources/branch_protection) | resource |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/6.8.3/docs/resources/repository) | resource |
| [github_repository_collaborator.this](https://registry.terraform.io/providers/integrations/github/6.8.3/docs/resources/repository_collaborator) | resource |
| [github_repository_deploy_key.this](https://registry.terraform.io/providers/integrations/github/6.8.3/docs/resources/repository_deploy_key) | resource |
| [github_repository_webhook.this](https://registry.terraform.io/providers/integrations/github/6.8.3/docs/resources/repository_webhook) | resource |
| [github_team_repository.this](https://registry.terraform.io/providers/integrations/github/6.8.3/docs/resources/team_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_default_branch_protection"></a> [create\_default\_branch\_protection](#input\_create\_default\_branch\_protection) | Whether to create default branch protection rules for repositories | `bool` | `true` | no |
| <a name="input_organization_secrets"></a> [organization\_secrets](#input\_organization\_secrets) | Organization-level secrets to create and optionally associate with specific repositories | <pre>map(object({<br/>    plaintext_value         = string<br/>    visibility              = optional(string, "all") # all, private, selected<br/>    selected_repository_ids = optional(list(number), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_organization_variables"></a> [organization\_variables](#input\_organization\_variables) | Organization-level variables to create and optionally associate with specific repositories | <pre>map(object({<br/>    value                   = string<br/>    visibility              = optional(string, "all") # all, private, selected<br/>    selected_repository_ids = optional(list(number), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | Map of repositories to create and manage in the GitHub Enterprise organization.<br/>Each key is the repository name, and the value contains all repository settings. | <pre>map(object({<br/>    description                 = optional(string, "")<br/>    visibility                  = optional(string, "private")<br/>    homepage_url                = optional(string)<br/>    has_issues                  = optional(bool, true)<br/>    has_projects                = optional(bool, false)<br/>    has_wiki                    = optional(bool, false)<br/>    has_discussions             = optional(bool, false)<br/>    has_downloads               = optional(bool, false)<br/>    allow_merge_commit          = optional(bool, true)<br/>    allow_squash_merge          = optional(bool, true)<br/>    allow_rebase_merge          = optional(bool, true)<br/>    allow_auto_merge            = optional(bool, false)<br/>    squash_merge_commit_title   = optional(string, "COMMIT_OR_PR_TITLE")<br/>    squash_merge_commit_message = optional(string, "COMMIT_MESSAGES")<br/>    merge_commit_title          = optional(string, "MERGE_MESSAGE")<br/>    merge_commit_message        = optional(string, "PR_TITLE")<br/>    delete_branch_on_merge      = optional(bool, true)<br/>    auto_init                   = optional(bool, true)<br/>    gitignore_template          = optional(string)<br/>    license_template            = optional(string)<br/>    archived                    = optional(bool, false)<br/>    archive_on_destroy          = optional(bool, true)<br/>    topics                      = optional(list(string), [])<br/>    vulnerability_alerts        = optional(bool, true)<br/><br/>    # Branch protection settings<br/>    default_branch = optional(string, "main")<br/>    branch_protection = optional(object({<br/>      pattern                         = optional(string, "main")<br/>      enforce_admins                  = optional(bool, true)<br/>      require_signed_commits          = optional(bool, false)<br/>      required_linear_history         = optional(bool, false)<br/>      require_conversation_resolution = optional(bool, true)<br/><br/>      required_status_checks = optional(object({<br/>        strict   = optional(bool, true)<br/>        contexts = optional(list(string), [])<br/>      }))<br/><br/>      required_pull_request_reviews = optional(object({<br/>        dismiss_stale_reviews           = optional(bool, true)<br/>        require_code_owner_reviews      = optional(bool, true)<br/>        required_approving_review_count = optional(number, 1)<br/>        require_last_push_approval      = optional(bool, false)<br/>        restrict_dismissals             = optional(bool, false)<br/>        dismissal_restrictions          = optional(list(string), [])<br/>      }))<br/><br/>      restrictions = optional(object({<br/>        users = optional(list(string), [])<br/>        teams = optional(list(string), [])<br/>        apps  = optional(list(string), [])<br/>      }))<br/>    }))<br/><br/>    # Team access<br/>    teams = optional(map(object({<br/>      permission = string # pull, triage, push, maintain, admin<br/>    })), {})<br/><br/>    # Collaborators<br/>    collaborators = optional(map(object({<br/>      permission = string # pull, triage, push, maintain, admin<br/>    })), {})<br/><br/>    # Deploy keys<br/>    deploy_keys = optional(map(object({<br/>      key       = string<br/>      read_only = optional(bool, true)<br/>    })), {})<br/><br/>    # Webhooks<br/>    webhooks = optional(map(object({<br/>      url          = string<br/>      content_type = optional(string, "json")<br/>      secret       = optional(string)<br/>      insecure_ssl = optional(bool, false)<br/>      active       = optional(bool, true)<br/>      events       = list(string)<br/>    })), {})<br/><br/>    # Repository secrets<br/>    secrets = optional(map(object({<br/>      plaintext_value = string<br/>    })), {})<br/><br/>    # Repository variables<br/>    variables = optional(map(object({<br/>      value = string<br/>    })), {})<br/><br/>    # Pages configuration<br/>    pages = optional(object({<br/>      source = object({<br/>        branch = string<br/>        path   = optional(string, "/")<br/>      })<br/>      cname = optional(string)<br/>    }))<br/><br/>    # Security and analysis<br/>    security_and_analysis = optional(object({<br/>      advanced_security = optional(object({<br/>        status = string # enabled or disabled<br/>      }))<br/>      secret_scanning = optional(object({<br/>        status = string # enabled or disabled<br/>      }))<br/>      secret_scanning_push_protection = optional(object({<br/>        status = string # enabled or disabled<br/>      }))<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_template_repository"></a> [template\_repository](#input\_template\_repository) | Template repository to use when creating new repositories | <pre>object({<br/>    owner                = string<br/>    repository           = string<br/>    include_all_branches = optional(bool, false)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_branch_protections"></a> [branch\_protections](#output\_branch\_protections) | Map of branch protection rules created |
| <a name="output_collaborators"></a> [collaborators](#output\_collaborators) | Map of repository collaborators |
| <a name="output_deploy_keys"></a> [deploy\_keys](#output\_deploy\_keys) | Map of deploy keys created |
| <a name="output_organization_secrets"></a> [organization\_secrets](#output\_organization\_secrets) | Map of organization secrets created (values not included) |
| <a name="output_organization_variables"></a> [organization\_variables](#output\_organization\_variables) | Map of organization variables created |
| <a name="output_repositories"></a> [repositories](#output\_repositories) | Map of all created repositories with their full details |
| <a name="output_repository_clone_urls"></a> [repository\_clone\_urls](#output\_repository\_clone\_urls) | Map of repository names to their SSH clone URLs |
| <a name="output_repository_ids"></a> [repository\_ids](#output\_repository\_ids) | Map of repository names to their numeric IDs |
| <a name="output_repository_node_ids"></a> [repository\_node\_ids](#output\_repository\_node\_ids) | Map of repository names to their node IDs |
| <a name="output_repository_urls"></a> [repository\_urls](#output\_repository\_urls) | Map of repository names to their HTML URLs |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | Map of repository secrets created (values not included) |
| <a name="output_team_access"></a> [team\_access](#output\_team\_access) | Map of team repository access configurations |
| <a name="output_variables"></a> [variables](#output\_variables) | Map of repository variables created |
| <a name="output_webhooks"></a> [webhooks](#output\_webhooks) | Map of webhooks created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
=======
## Overview

Terraform module to create repositories in an existing GitHub Enterprise Organization.

## Features

- Creates one or many GitHub repositories in an existing organization


## Prerequisites

- Terraform 1.6+ and GitHub provider `integrations/github` 6.8.3+
- EMU-enabled GitHub Enterprise organization
>>>>>>> 03a4b8b31cfd3bae3d2c27169d47e3c2480107ba
