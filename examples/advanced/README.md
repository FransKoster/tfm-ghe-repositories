# Advanced Repository Example

This example demonstrates advanced usage of the GitHub Enterprise repositories module with:

- Branch protection rules
- Team access configuration
- Deploy keys
- Webhooks
- Repository secrets and variables
- Security settings

## Usage

```bash
# Set required environment variables
export GITHUB_TOKEN="ghp_your_token"
export TF_VAR_webhook_secret="your-webhook-secret"
export TF_VAR_deploy_key="ssh-rsa AAAA..."
export TF_VAR_api_key="your-api-key"

terraform init
terraform plan
terraform apply
```

## Configuration

The example creates:

- A production application repository with strict branch protection
- A staging repository with team access and webhooks
- Organization-level secrets and variables

## Cleanup

```bash
terraform destroy
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 6.8.3 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_repositories"></a> [repositories](#module\_repositories) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | API key for application | `string` | n/a | yes |
| <a name="input_deploy_key"></a> [deploy\_key](#input\_deploy\_key) | SSH public key for deployment | `string` | n/a | yes |
| <a name="input_github_base_url"></a> [github\_base\_url](#input\_github\_base\_url) | Base URL for GitHub Enterprise instance | `string` | `"https://company.ghe.com/"` | no |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | GitHub organization name | `string` | n/a | yes |
| <a name="input_webhook_secret"></a> [webhook\_secret](#input\_webhook\_secret) | Secret for webhook authentication | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_branch_protections"></a> [branch\_protections](#output\_branch\_protections) | Branch protection rules |
| <a name="output_repositories"></a> [repositories](#output\_repositories) | All repository details |
| <a name="output_repository_urls"></a> [repository\_urls](#output\_repository\_urls) | URLs of the created repositories |
| <a name="output_team_access"></a> [team\_access](#output\_team\_access) | Team access configurations |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
