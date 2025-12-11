variable "github_organization" {
  type        = string
  description = "GitHub organization name"
}

variable "github_base_url" {
  type        = string
  description = "Base URL for GitHub Enterprise instance"
  default     = "https://company.ghe.com/"
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
