output "repositories" {
  description = "All repository details"
  value       = module.repositories.repositories
}

output "repository_urls" {
  description = "URLs of the created repositories"
  value       = module.repositories.repository_urls
}

output "branch_protections" {
  description = "Branch protection rules"
  value       = module.repositories.branch_protections
}

output "team_access" {
  description = "Team access configurations"
  value       = module.repositories.team_access
}
