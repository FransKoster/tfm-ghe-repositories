output "repositories" {
  description = "Map of all created repositories with their full details"
  value = {
    for k, v in github_repository.this : k => {
      id             = v.id
      name           = v.name
      full_name      = v.full_name
      node_id        = v.node_id
      description    = v.description
      visibility     = v.visibility
      homepage_url   = v.homepage_url
      html_url       = v.html_url
      ssh_clone_url  = v.ssh_clone_url
      http_clone_url = v.http_clone_url
      git_clone_url  = v.git_clone_url
      svn_url        = v.svn_url
      default_branch = v.default_branch
      topics         = v.topics
      archived       = v.archived
    }
  }
}

output "repository_ids" {
  description = "Map of repository names to their numeric IDs"
  value = {
    for k, v in github_repository.this : k => v.repo_id
  }
}

output "repository_node_ids" {
  description = "Map of repository names to their node IDs"
  value = {
    for k, v in github_repository.this : k => v.node_id
  }
}

output "repository_urls" {
  description = "Map of repository names to their HTML URLs"
  value = {
    for k, v in github_repository.this : k => v.html_url
  }
}

output "repository_clone_urls" {
  description = "Map of repository names to their SSH clone URLs"
  value = {
    for k, v in github_repository.this : k => v.ssh_clone_url
  }
}

output "branch_protections" {
  description = "Map of branch protection rules created"
  value = {
    for k, v in github_branch_protection.this : k => {
      repository_id = v.repository_id
      pattern       = v.pattern
    }
  }
}

output "team_access" {
  description = "Map of team repository access configurations"
  value = {
    for k, v in github_team_repository.this : k => {
      repository = v.repository
      team_id    = v.team_id
      permission = v.permission
    }
  }
}

output "collaborators" {
  description = "Map of repository collaborators"
  value = {
    for k, v in github_repository_collaborator.this : k => {
      repository = v.repository
      username   = v.username
      permission = v.permission
    }
  }
}

output "deploy_keys" {
  description = "Map of deploy keys created"
  value = {
    for k, v in github_repository_deploy_key.this : k => {
      repository = v.repository
      title      = v.title
      read_only  = v.read_only
    }
  }
  sensitive = true
}

output "webhooks" {
  description = "Map of webhooks created"
  value = {
    for k, v in github_repository_webhook.this : k => {
      repository = v.repository
      url        = v.url
      active     = v.active
      events     = v.events
    }
  }
  sensitive = true
}

output "secrets" {
  description = "Map of repository secrets created (values not included)"
  value = {
    for k, v in github_actions_secret.this : k => {
      repository  = v.repository
      secret_name = v.secret_name
    }
  }
}

output "variables" {
  description = "Map of repository variables created"
  value = {
    for k, v in github_actions_variable.this : k => {
      repository    = v.repository
      variable_name = v.variable_name
      value         = v.value
    }
  }
}

output "organization_secrets" {
  description = "Map of organization secrets created (values not included)"
  value = {
    for k, v in github_actions_organization_secret.this : k => {
      secret_name = v.secret_name
      visibility  = v.visibility
    }
  }
}

output "organization_variables" {
  description = "Map of organization variables created"
  value = {
    for k, v in github_actions_organization_variable.this : k => {
      variable_name = v.variable_name
      visibility    = v.visibility
      value         = v.value
    }
  }
}
