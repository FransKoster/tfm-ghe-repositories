# Basic Repository Example

This example demonstrates basic usage of the GitHub Enterprise repositories module to create simple repositories.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Configuration

The example creates two basic repositories with minimal configuration:

- A private repository with default settings
- A public repository with basic customization

## Cleanup

```bash
terraform destroy
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.0.0 |

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
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | GitHub organization name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repository_clone_urls"></a> [repository\_clone\_urls](#output\_repository\_clone\_urls) | SSH clone URLs of the created repositories |
| <a name="output_repository_urls"></a> [repository\_urls](#output\_repository\_urls) | URLs of the created repositories |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
