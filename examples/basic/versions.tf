terraform {
  required_version = ">= 1.6.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.0.0"
    }
  }
}

provider "github" {
  owner    = var.github_organization
  base_url = var.github_base_url
}
