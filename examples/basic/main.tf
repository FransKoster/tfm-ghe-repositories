module "repositories" {
  source = "../../"

  repositories = {
    my-app = {
      description = "My application repository"
      visibility  = "private"

      has_issues   = true
      has_wiki     = false
      has_projects = false

      topics = ["terraform", "github", "example"]

      delete_branch_on_merge = true
      auto_init              = true
      gitignore_template     = "Terraform"
      license_template       = "mit"
    }

    my-docs = {
      description = "Documentation repository"
      visibility  = "public"

      has_issues = true
      has_wiki   = true

      topics = ["documentation"]

      auto_init          = true
      gitignore_template = "Jekyll"
    }
  }
}
