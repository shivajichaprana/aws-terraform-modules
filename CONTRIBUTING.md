# Contributing to aws-terraform-modules

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Development Setup

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5
- [TFLint](https://github.com/terraform-linters/tflint) >= 0.50
- [terraform-docs](https://terraform-docs.io/) >= 0.17
- Git

### Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/aws-terraform-modules.git`
3. Create a feature branch: `git checkout -b feat/your-feature-name`
4. Make your changes
5. Run validation: `terraform fmt -recursive && terraform validate`
6. Push and create a Pull Request

## Code Standards

### Naming Conventions

- Use `snake_case` for all Terraform resource names, variables, and outputs
- Prefix resources with `this` when there's a primary resource (e.g., `aws_vpc.this`)
- Use descriptive variable names with clear `description` fields

### Module Structure

Every module must contain:

```
modules/<module-name>/
├── main.tf          # Primary resources
├── variables.tf     # Input variables with descriptions and validations
├── outputs.tf       # Output values with descriptions
├── versions.tf      # Provider and Terraform version constraints
└── README.md        # Module documentation (auto-generated sections)
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add CloudFront module with S3 origin support
fix: resolve VPC flow log IAM role permission issue
docs: update VPC module usage examples
test: add validation tests for S3 module variables
ci: add Checkov security scanning to pipeline
refactor: extract subnet calculation into locals
```

### Variable Conventions

- Always include `description` for every variable
- Add `validation` blocks for inputs that have constraints
- Use `default` values for optional configuration
- Group variables logically with comment headers

### Testing

Before submitting a PR:

1. Run `terraform fmt -check -recursive` — code must be formatted
2. Run `terraform validate` in each module directory
3. Run `tflint` in each module directory
4. Ensure the CI pipeline passes on your PR

## Pull Request Process

1. Update the README.md if you've added new modules or changed interfaces
2. Ensure all CI checks pass
3. Add a clear description of what changed and why
4. Link any related issues

## Adding a New Module

1. Create the module directory under `modules/`
2. Follow the standard module structure above
3. Add an example under `examples/`
4. Add the module to the CI matrix in `.github/workflows/validate.yml`
5. Update the root README.md module table
6. Submit a PR

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.
