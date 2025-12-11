output "repository_urls" {
  description = "URLs of the created repositories"
  value       = module.repositories.repository_urls
}

output "repository_clone_urls" {
  description = "SSH clone URLs of the created repositories"
  value       = module.repositories.repository_clone_urls
}
