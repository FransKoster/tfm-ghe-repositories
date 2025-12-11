#--------------------------------------------------------------
# Repository Creation
#--------------------------------------------------------------

resource "github_repository" "this" {
  for_each = var.repositories

  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility

  homepage_url    = each.value.homepage_url
  has_issues      = each.value.has_issues
  has_projects    = each.value.has_projects
  has_wiki        = each.value.has_wiki
  has_discussions = each.value.has_discussions
  has_downloads   = each.value.has_downloads

  allow_merge_commit = each.value.allow_merge_commit
  allow_squash_merge = each.value.allow_squash_merge
  allow_rebase_merge = each.value.allow_rebase_merge
  allow_auto_merge   = each.value.allow_auto_merge

  squash_merge_commit_title   = each.value.squash_merge_commit_title
  squash_merge_commit_message = each.value.squash_merge_commit_message
  merge_commit_title          = each.value.merge_commit_title
  merge_commit_message        = each.value.merge_commit_message

  delete_branch_on_merge = each.value.delete_branch_on_merge
  auto_init              = each.value.auto_init
  gitignore_template     = each.value.gitignore_template
  license_template       = each.value.license_template
  archived               = each.value.archived
  archive_on_destroy     = each.value.archive_on_destroy

  topics = each.value.topics

  vulnerability_alerts = each.value.vulnerability_alerts

  dynamic "template" {
    for_each = var.template_repository != null ? [var.template_repository] : []
    content {
      owner                = template.value.owner
      repository           = template.value.repository
      include_all_branches = template.value.include_all_branches
    }
  }

  dynamic "pages" {
    for_each = each.value.pages != null ? [each.value.pages] : []
    content {
      source {
        branch = pages.value.source.branch
        path   = pages.value.source.path
      }
      cname = pages.value.cname
    }
  }

  dynamic "security_and_analysis" {
    for_each = each.value.security_and_analysis != null ? [each.value.security_and_analysis] : []
    content {
      dynamic "advanced_security" {
        for_each = security_and_analysis.value.advanced_security != null ? [security_and_analysis.value.advanced_security] : []
        content {
          status = advanced_security.value.status
        }
      }
      dynamic "secret_scanning" {
        for_each = security_and_analysis.value.secret_scanning != null ? [security_and_analysis.value.secret_scanning] : []
        content {
          status = secret_scanning.value.status
        }
      }
      dynamic "secret_scanning_push_protection" {
        for_each = security_and_analysis.value.secret_scanning_push_protection != null ? [security_and_analysis.value.secret_scanning_push_protection] : []
        content {
          status = secret_scanning_push_protection.value.status
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      auto_init,
      gitignore_template,
      license_template,
    ]
  }
}

#--------------------------------------------------------------
# Branch Protection
#--------------------------------------------------------------

resource "github_branch_protection" "this" {
  for_each = {
    for k, v in var.repositories : k => v
    if var.create_default_branch_protection && v.branch_protection != null
  }

  repository_id = github_repository.this[each.key].node_id
  pattern       = each.value.branch_protection.pattern

  enforce_admins                  = each.value.branch_protection.enforce_admins
  require_signed_commits          = each.value.branch_protection.require_signed_commits
  required_linear_history         = each.value.branch_protection.required_linear_history
  require_conversation_resolution = each.value.branch_protection.require_conversation_resolution

  dynamic "required_status_checks" {
    for_each = each.value.branch_protection.required_status_checks != null ? [each.value.branch_protection.required_status_checks] : []
    content {
      strict   = required_status_checks.value.strict
      contexts = required_status_checks.value.contexts
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = each.value.branch_protection.required_pull_request_reviews != null ? [each.value.branch_protection.required_pull_request_reviews] : []
    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value.dismiss_stale_reviews
      require_code_owner_reviews      = required_pull_request_reviews.value.require_code_owner_reviews
      required_approving_review_count = required_pull_request_reviews.value.required_approving_review_count
      require_last_push_approval      = required_pull_request_reviews.value.require_last_push_approval
      restrict_dismissals             = required_pull_request_reviews.value.restrict_dismissals
      dismissal_restrictions          = required_pull_request_reviews.value.dismissal_restrictions
    }
  }

  dynamic "restrict_pushes" {
    for_each = each.value.branch_protection.restrictions != null ? [each.value.branch_protection.restrictions] : []
    content {
      blocks_creations = false
    }
  }
}

#--------------------------------------------------------------
# Team Access
#--------------------------------------------------------------

resource "github_team_repository" "this" {
  for_each = merge([
    for repo_name, repo_config in var.repositories : {
      for team_slug, team_config in repo_config.teams :
      "${repo_name}/${team_slug}" => {
        repository = repo_name
        team_id    = team_slug
        permission = team_config.permission
      }
    }
  ]...)

  repository = github_repository.this[each.value.repository].name
  team_id    = each.value.team_id
  permission = each.value.permission
}

#--------------------------------------------------------------
# Collaborators
#--------------------------------------------------------------

resource "github_repository_collaborator" "this" {
  for_each = merge([
    for repo_name, repo_config in var.repositories : {
      for username, collab_config in repo_config.collaborators :
      "${repo_name}/${username}" => {
        repository = repo_name
        username   = username
        permission = collab_config.permission
      }
    }
  ]...)

  repository = github_repository.this[each.value.repository].name
  username   = each.value.username
  permission = each.value.permission
}

#--------------------------------------------------------------
# Deploy Keys
#--------------------------------------------------------------

resource "github_repository_deploy_key" "this" {
  for_each = merge([
    for repo_name, repo_config in var.repositories : {
      for key_name, key_config in repo_config.deploy_keys :
      "${repo_name}/${key_name}" => {
        repository = repo_name
        title      = key_name
        key        = key_config.key
        read_only  = key_config.read_only
      }
    }
  ]...)

  repository = github_repository.this[each.value.repository].name
  title      = each.value.title
  key        = each.value.key
  read_only  = each.value.read_only
}

#--------------------------------------------------------------
# Webhooks
#--------------------------------------------------------------

resource "github_repository_webhook" "this" {
  for_each = merge([
    for repo_name, repo_config in var.repositories : {
      for webhook_name, webhook_config in repo_config.webhooks :
      "${repo_name}/${webhook_name}" => {
        repository   = repo_name
        url          = webhook_config.url
        content_type = webhook_config.content_type
        secret       = webhook_config.secret
        insecure_ssl = webhook_config.insecure_ssl
        active       = webhook_config.active
        events       = webhook_config.events
      }
    }
  ]...)

  repository = github_repository.this[each.value.repository].name
  active     = each.value.active
  events     = each.value.events

  configuration {
    url          = each.value.url
    content_type = each.value.content_type
    secret       = each.value.secret
    insecure_ssl = each.value.insecure_ssl
  }
}

#--------------------------------------------------------------
# Repository Secrets
#--------------------------------------------------------------

resource "github_actions_secret" "this" {
  for_each = merge([
    for repo_name, repo_config in var.repositories : {
      for secret_name, secret_config in repo_config.secrets :
      "${repo_name}/${secret_name}" => {
        repository      = repo_name
        secret_name     = secret_name
        plaintext_value = secret_config.plaintext_value
      }
    }
  ]...)

  repository      = github_repository.this[each.value.repository].name
  secret_name     = each.value.secret_name
  plaintext_value = each.value.plaintext_value
}

#--------------------------------------------------------------
# Repository Variables
#--------------------------------------------------------------

resource "github_actions_variable" "this" {
  for_each = merge([
    for repo_name, repo_config in var.repositories : {
      for var_name, var_config in repo_config.variables :
      "${repo_name}/${var_name}" => {
        repository    = repo_name
        variable_name = var_name
        value         = var_config.value
      }
    }
  ]...)

  repository    = github_repository.this[each.value.repository].name
  variable_name = each.value.variable_name
  value         = each.value.value
}

#--------------------------------------------------------------
# Organization Secrets
#--------------------------------------------------------------

resource "github_actions_organization_secret" "this" {
  for_each = var.organization_secrets

  secret_name             = each.key
  visibility              = each.value.visibility
  plaintext_value         = each.value.plaintext_value
  selected_repository_ids = each.value.selected_repository_ids
}

#--------------------------------------------------------------
# Organization Variables
#--------------------------------------------------------------

resource "github_actions_organization_variable" "this" {
  for_each = var.organization_variables

  variable_name           = each.key
  visibility              = each.value.visibility
  value                   = each.value.value
  selected_repository_ids = each.value.selected_repository_ids
}
