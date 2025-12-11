module "repositories" {
  source = "../../"

  repositories = {
    production-app = {
      description = "Production application repository"
      visibility  = "private"

      has_issues      = true
      has_wiki        = false
      has_projects    = true
      has_discussions = false

      topics = ["production", "application", "terraform-managed"]

      # Merge settings
      allow_merge_commit     = false
      allow_squash_merge     = true
      allow_rebase_merge     = false
      allow_auto_merge       = true
      delete_branch_on_merge = true

      # Squash merge settings
      squash_merge_commit_title   = "PR_TITLE"
      squash_merge_commit_message = "COMMIT_MESSAGES"

      # Security
      vulnerability_alerts = true

      auto_init          = true
      gitignore_template = "Terraform"
      license_template   = "apache-2.0"

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

      # Team access
      teams = {
        "platform-team" = {
          permission = "admin"
        }
        "dev-team" = {
          permission = "push"
        }
      }

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
      }

      # Repository secrets
      secrets = {
        "API_KEY" = {
          plaintext_value = var.api_key
        }
        "DEPLOY_TOKEN" = {
          plaintext_value = "ghp_deploytoken123"
        }
      }

      # Repository variables
      variables = {
        "ENVIRONMENT" = {
          value = "production"
        }
        "DEPLOY_REGION" = {
          value = "eu-west-1"
        }
      }

      # Security and analysis
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

    staging-app = {
      description = "Staging application repository"
      visibility  = "private"

      has_issues   = true
      has_wiki     = false
      has_projects = false

      topics = ["staging", "application"]

      allow_squash_merge     = true
      delete_branch_on_merge = true

      auto_init          = true
      gitignore_template = "Terraform"

      # Branch protection (less strict than production)
      branch_protection = {
        pattern        = "main"
        enforce_admins = false

        required_status_checks = {
          strict   = true
          contexts = ["ci/build", "ci/test"]
        }

        required_pull_request_reviews = {
          dismiss_stale_reviews           = true
          require_code_owner_reviews      = false
          required_approving_review_count = 1
        }
      }

      # Team access
      teams = {
        "dev-team" = {
          permission = "admin"
        }
      }

      # Repository variables
      variables = {
        "ENVIRONMENT" = {
          value = "staging"
        }
        "DEPLOY_REGION" = {
          value = "eu-west-1"
        }
      }
    }

    documentation = {
      description = "Project documentation"
      visibility  = "public"

      has_issues = true
      has_wiki   = true

      topics = ["documentation", "public"]

      auto_init          = true
      gitignore_template = "Jekyll"
      license_template   = "cc-by-4.0"

      # GitHub Pages
      pages = {
        source = {
          branch = "main"
          path   = "/docs"
        }
      }

      # Team access
      teams = {
        "platform-team" = {
          permission = "maintain"
        }
      }
    }
  }

  # Organization-level secrets (shared across repositories)
  organization_secrets = {
    "ORG_DOCKER_REGISTRY_TOKEN" = {
      plaintext_value = "docker_token_xyz"
      visibility      = "private"
    }
    "ORG_NPM_TOKEN" = {
      plaintext_value = "npm_token_abc"
      visibility      = "all"
    }
  }

  # Organization-level variables
  organization_variables = {
    "ORG_DOMAIN" = {
      value      = "example.com"
      visibility = "all"
    }
    "ORG_SUPPORT_EMAIL" = {
      value      = "support@example.com"
      visibility = "all"
    }
  }

  create_default_branch_protection = true
}
