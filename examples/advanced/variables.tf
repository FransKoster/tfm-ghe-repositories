variable "github_organization" {
  type        = string
  description = "GitHub organization name"
}

variable "webhook_secret" {
  type        = string
  description = "Secret for webhook authentication"
  sensitive   = true
}

variable "deploy_key" {
  type        = string
  description = "SSH public key for deployment"
}

variable "api_key" {
  type        = string
  description = "API key for application"
  sensitive   = true
}
