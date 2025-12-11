variable "repositories" {
  type = map(object({
    description                 = optional(string, "")
    visibility                  = optional(string, "private")
    homepage_url                = optional(string)
    has_issues                  = optional(bool, true)
    has_projects                = optional(bool, false)
    has_wiki                    = optional(bool, false)
    has_discussions             = optional(bool, false)
    has_downloads               = optional(bool, false)
    allow_merge_commit          = optional(bool, true)
    allow_squash_merge          = optional(bool, true)
    allow_rebase_merge          = optional(bool, true)
    allow_auto_merge            = optional(bool, false)
    squash_merge_commit_title   = optional(string, "COMMIT_OR_PR_TITLE")
    squash_merge_commit_message = optional(string, "COMMIT_MESSAGES")
    merge_commit_title          = optional(string, "MERGE_MESSAGE")
    merge_commit_message        = optional(string, "PR_TITLE")
    delete_branch_on_merge      = optional(bool, true)
    auto_init                   = optional(bool, true)
    gitignore_template          = optional(string)
    license_template            = optional(string)
    archived                    = optional(bool, false)
    archive_on_destroy          = optional(bool, true)
    topics                      = optional(list(string), [])
    vulnerability_alerts        = optional(bool, true)

    # Branch protection settings
    default_branch = optional(string, "main")
    branch_protection = optional(object({
      pattern                         = optional(string, "main")
      enforce_admins                  = optional(bool, true)
      require_signed_commits          = optional(bool, false)
      required_linear_history         = optional(bool, false)
      require_conversation_resolution = optional(bool, true)

      required_status_checks = optional(object({
        strict   = optional(bool, true)
        contexts = optional(list(string), [])
      }))

      required_pull_request_reviews = optional(object({
        dismiss_stale_reviews           = optional(bool, true)
        require_code_owner_reviews      = optional(bool, true)
        required_approving_review_count = optional(number, 1)
        require_last_push_approval      = optional(bool, false)
        restrict_dismissals             = optional(bool, false)
        dismissal_restrictions          = optional(list(string), [])
      }))

      restrictions = optional(object({
        users = optional(list(string), [])
        teams = optional(list(string), [])
        apps  = optional(list(string), [])
      }))
    }))

    # Team access
    teams = optional(map(object({
      permission = string # pull, triage, push, maintain, admin
    })), {})

    # Collaborators
    collaborators = optional(map(object({
      permission = string # pull, triage, push, maintain, admin
    })), {})

    # Deploy keys
    deploy_keys = optional(map(object({
      key       = string
      read_only = optional(bool, true)
    })), {})

    # Webhooks
    webhooks = optional(map(object({
      url          = string
      content_type = optional(string, "json")
      secret       = optional(string)
      insecure_ssl = optional(bool, false)
      active       = optional(bool, true)
      events       = list(string)
    })), {})

    # Repository secrets
    secrets = optional(map(object({
      plaintext_value = string
    })), {})

    # Repository variables
    variables = optional(map(object({
      value = string
    })), {})

    # Pages configuration
    pages = optional(object({
      source = object({
        branch = string
        path   = optional(string, "/")
      })
      cname = optional(string)
    }))

    # Security and analysis
    security_and_analysis = optional(object({
      advanced_security = optional(object({
        status = string # enabled or disabled
      }))
      secret_scanning = optional(object({
        status = string # enabled or disabled
      }))
      secret_scanning_push_protection = optional(object({
        status = string # enabled or disabled
      }))
    }))
  }))

  description = <<-EOT
    Map of repositories to create and manage in the GitHub Enterprise organization.
    Each key is the repository name, and the value contains all repository settings.
  EOT
}

variable "organization_secrets" {
  type = map(object({
    plaintext_value         = string
    visibility              = optional(string, "all") # all, private, selected
    selected_repository_ids = optional(list(number), [])
  }))
  default     = {}
  description = "Organization-level secrets to create and optionally associate with specific repositories"
}

variable "organization_variables" {
  type = map(object({
    value                   = string
    visibility              = optional(string, "all") # all, private, selected
    selected_repository_ids = optional(list(number), [])
  }))
  default     = {}
  description = "Organization-level variables to create and optionally associate with specific repositories"
}

variable "create_default_branch_protection" {
  type        = bool
  default     = true
  description = "Whether to create default branch protection rules for repositories"
}

variable "template_repository" {
  type = object({
    owner                = string
    repository           = string
    include_all_branches = optional(bool, false)
  })
  default     = null
  description = "Template repository to use when creating new repositories"
}
