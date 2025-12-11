---
post_title: "GitHub EMU Teams Terraform Module"
author1: "FKoster"
post_slug: "github-emu-teams-terraform-module"
microsoft_alias: "fkoster"
featured_image: ""
categories: ["devops"]
tags: ["terraform", "github", "emu", "teams", "scim"]
ai_note: "Assisted by GPT-5.1-Codex-Max (Preview)."
summary: "Provision GitHub teams and sync Enterprise Managed User IdP groups with Terraform."
post_date: "2025-12-11"
---

## Overview

Terraform module to create GitHub teams and attach Enterprise Managed User (EMU) IdP external groups using `github_emu_group_mapping`. The module resolves IdP group names to IDs automatically and fails fast if a requested group name is unknown.

## Features

- Creates one or many GitHub teams in an EMU org
- Looks up EMU external groups by name, enforcing existence with a precondition
- Exposes created teams, mappings, and discovered external groups as outputs
- Keeps team sync IdP-driven by using `github_emu_group_mapping`

## Prerequisites

- Terraform 1.6+ and GitHub provider `integrations/github` 6.8.3+
- EMU-enabled GitHub Enterprise organization
- Token or GitHub App credentials with `admin:org` and team management rights, SSO authorized for the org

> [!NOTE]
> The module reads EMU external groups via `data "github_external_groups"` and will error with the missing names it cannot find.

## Quickstart

1. Export credentials (PAT example):
   ```bash
   export GITHUB_TOKEN=ghp_your_token
   ```
2. Set the org owner in `terraform.tfvars` (for provider `owner`).
3. Run:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Module Inputs

- `teams` (map):
  - `name` (string) – team display name
  - `description` (string, optional)
  - `privacy` (string, default `closed`, allowed `closed` or `secret`)
  - `parent_team_id` (string, optional)
  - `idp_group_names` (list[string]) – EMU external group names to map

## Module Outputs

- `external_groups` – all EMU external groups discovered
- `teams` – ids, slugs, and node_ids per team key
- `group_mappings` – created EMU mappings (group_id, team_slug, etag)

## Usage

Minimal example with IdP group name lookup:

```hcl
provider "github" {
  owner = var.owner
}

module "emu_teams" {
  source = "../../"

  teams = {
    platform = {
      name            = "Platform"
      description     = "Shared platform engineering team"
      privacy         = "closed"
      idp_group_names = [
        "ghe-cloudregie-admins",
      ]
    }

    data = {
      name            = "Data"
      description     = "Data engineering team"
      privacy         = "closed"
      idp_group_names = [
        "ghe-data-engineers",
      ]
    }
  }
}
```

## Validation Behavior

- The module fails during planning if any `idp_group_names` are missing from EMU external groups and prints the missing names.

## Project Layout

- `modules/emu-teams/` – core module (teams, EMU group lookup, mappings)
- `examples/emu-teams/` – static group IDs example
- `examples/emu-teams-with-lookup/` – name-based lookup example (recommended)

## Tips

- Keep `idp_group_names` aligned with the names visible under **Organization settings → Security → External groups**.
- Prefer `privacy = "closed"` for standard teams; use `secret` only when necessary.
- If you add parent teams, set `parent_team_id` to the parent’s numeric team ID.Reference for manual linking of EMU IdP groups to teams in an existing organization:

https://docs.github.com/en/enterprise-cloud@latest/admin/managing-iam/provisioning-user-accounts-with-scim/managing-team-memberships-with-identity-provider-groups

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.6.0 |
| <a name="requirement_github"></a> [github](#requirement_github)          | >= 6.8.3 |

## Providers

| Name                                                               | Version |
| ------------------------------------------------------------------ | ------- |
| <a name="provider_github"></a> [github](#provider_github)          | 6.9.0   |
| <a name="provider_terraform"></a> [terraform](#provider_terraform) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                 | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [github_emu_group_mapping.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/emu_group_mapping) | resource    |
| [github_team.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team)                           | resource    |
| [terraform_data.validate_group_names](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data)        | resource    |
| [github_external_groups.emu](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/external_groups)   | data source |

## Inputs

| Name                                             | Description                                                   | Type                                                                                                                                                                                                             | Default | Required |
| ------------------------------------------------ | ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_teams"></a> [teams](#input_teams) | Map of teams to create and their EMU IdP group names to link. | <pre>map(object({<br/> name = string<br/> description = optional(string, "")<br/> privacy = optional(string, "closed")<br/> parent_team_id = optional(string)<br/> idp_group_names = list(string)<br/> }))</pre> | n/a     |   yes    |

## Outputs

| Name                                                                             | Description                                            |
| -------------------------------------------------------------------------------- | ------------------------------------------------------ |
| <a name="output_external_groups"></a> [external_groups](#output_external_groups) | All EMU external groups available in the organization. |
| <a name="output_group_mappings"></a> [group_mappings](#output_group_mappings)    | EMU group mappings keyed by team and group id.         |
| <a name="output_teams"></a> [teams](#output_teams)                               | Details for each team created by the module.           |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
