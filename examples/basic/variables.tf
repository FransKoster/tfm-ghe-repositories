variable "github_organization" {
  type        = string
  description = "GitHub organization name"
}

variable "github_base_url" {
  type        = string
  description = "Base URL for GitHub Enterprise instance"
  default     = "https://prorail.ghe.com/"
}
