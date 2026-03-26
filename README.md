# aws-terraform-modules

![Terraform Validate](https://github.com/shivajichaprana/aws-terraform-modules/actions/workflows/validate.yml/badge.svg)
![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)
![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.5-blueviolet)

Production-grade, reusable Terraform modules for AWS infrastructure. Battle-tested patterns for VPC, S3, EKS, and RDS — with security baselines, automated validation, and auto-generated documentation.

## Why This Exists

Copy-pasting Terraform code across projects leads to infrastructure drift, security gaps, and maintenance nightmares. This module library provides **vetted, tested, reusable infrastructure patterns** with:

- Sensible defaults that follow the AWS Well-Architected Framework
- Security baselines baked in (encryption, public access blocking, flow logs, restricted defaults)
- Automated validation via GitHub Actions on every PR
- Auto-generated documentation that never goes stale

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        AWS Account                              │
│                                                                 │
│  ┌───────────────────── VPC Module ──────────────────────────┐  │
│  │  CIDR: 10.0.0.0/16                                       │  │
│  │                                                           │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │  │
│  │  │  Public-1a   │  │  Public-1b   │  │  Public-1c   │      │  │
│  │  │  10.0.0.0/24 │  │  10.0.1.0/24 │  │  10.0.2.0/24 │     │  │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │  │
│  │         │ IGW             │ IGW             │ IGW          │  │
│  │  ┌──────┴───────┐  ┌──────┴───────┐  ┌──────┴───────┐     │  │
│  │  │  NAT GW 1a   │  │  NAT GW 1b   │  │  NAT GW 1c   │    │  │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │  │
│  │  ┌──────┴───────┐  ┌──────┴───────┐  ┌──────┴───────┐     │  │
│  │  │ Private-1a   │  │ Private-1b   │  │ Private-1c   │      │  │
│  │  │ 10.0.3.0/24  │  │ 10.0.4.0/24  │  │ 10.0.5.0/24  │    │  │
│  │  │   ┌─────┐    │  │   ┌─────┐    │  │   ┌─────┐    │    │  │
│  │  │   │ EKS │    │  │   │ RDS │    │  │   │ App │    │     │  │
│  │  │   └─────┘    │  │   └─────┘    │  │   └─────┘    │     │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘      │  │
│  │                                                            │  │
│  │  Flow Logs → CloudWatch    Default SG → Restricted         │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──── S3 Module ─────┐                                        │
│  │ ✓ SSE-S3/KMS       │                                        │
│  │ ✓ Versioning       │                                        │
│  │ ✓ Public blocked   │                                        │
│  │ ✓ Lifecycle rules  │                                        │
│  └────────────────────┘                                        │
└─────────────────────────────────────────────────────────────────┘
```

## Available Modules

| Module | Description | Status |
|--------|-------------|--------|
| [vpc](./modules/vpc) | VPC with public/private subnets, NAT Gateway, flow logs, restricted default SG | ✅ Stable |
| [s3](./modules/s3) | S3 bucket with encryption, versioning, public access blocking, lifecycle rules | ✅ Stable |
| [eks](./modules/eks) | EKS cluster with managed node groups, IRSA, cluster logging | 🚧 Coming Soon |
| [rds](./modules/rds) | RDS/Aurora with multi-AZ, encryption, automated backups | 🚧 Coming Soon |

## Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5
- AWS CLI configured with appropriate credentials
- An AWS account (free tier works for most modules)

### Usage

```hcl
module "vpc" {
  source = "github.com/shivajichaprana/aws-terraform-modules//modules/vpc"

  name               = "production"
  cidr               = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  enable_nat_gateway = true
  single_nat_gateway = false  # Set true for non-prod to save ~$64/month
  enable_flow_logs   = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

module "app_bucket" {
  source = "github.com/shivajichaprana/aws-terraform-modules//modules/s3"

  bucket_name            = "myapp-production-assets"
  enable_versioning      = true
  enable_encryption      = true
  block_public_access    = true
  enable_lifecycle_rules = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### What This Would Deploy

<details>
<summary>Example terraform plan output (click to expand)</summary>

```
Terraform will perform the following actions:

  # module.vpc.aws_vpc.this will be created
  + resource "aws_vpc" "this" {
      + cidr_block           = "10.0.0.0/16"
      + enable_dns_hostnames = true
      + enable_dns_support   = true
      + tags                 = { "Name" = "production-vpc" }
    }

  # module.vpc.aws_subnet.public[0-2] will be created (3 subnets)
  # module.vpc.aws_subnet.private[0-2] will be created (3 subnets)
  # module.vpc.aws_internet_gateway.this will be created
  # module.vpc.aws_nat_gateway.this[0-2] will be created (3 NAT GWs)
  # module.vpc.aws_eip.nat[0-2] will be created (3 Elastic IPs)
  # module.vpc.aws_route_table.public will be created
  # module.vpc.aws_route_table.private[0-2] will be created
  # module.vpc.aws_flow_log.this will be created
  # module.vpc.aws_cloudwatch_log_group.flow_log will be created

  # module.app_bucket.aws_s3_bucket.this will be created
  # module.app_bucket.aws_s3_bucket_versioning.this will be created
  # module.app_bucket.aws_s3_bucket_server_side_encryption_configuration.this will be created
  # module.app_bucket.aws_s3_bucket_public_access_block.this will be created
  # module.app_bucket.aws_s3_bucket_lifecycle_configuration.this will be created

Plan: ~22 resources to add, 0 to change, 0 to destroy.
```

</details>

### Full Example

See [`examples/full-stack`](./examples/full-stack) for a complete working example that deploys a VPC with multiple S3 buckets using all available modules together.

## CI/CD Pipeline

Every push and pull request automatically runs:

| Check | Tool | Purpose |
|-------|------|---------|
| Format | `terraform fmt` | Enforces consistent HCL formatting |
| Validate | `terraform validate` | Catches syntax errors and provider issues |
| Lint | `tflint` | AWS-specific best practices and naming conventions |
| Security | `checkov` | Scans for security misconfigurations (CIS benchmarks) |
| Docs | `terraform-docs` | Auto-generates module documentation on merge |

## Module Design Principles

**Secure by default** — Encryption enabled, public access blocked, flow logs on, default security group restricted. You opt OUT of security, never opt in.

**Minimal required inputs** — Most modules need 2-3 required variables. Everything else has sensible defaults that work for production.

**Cost-aware** — Single NAT Gateway option for non-production, lifecycle rules for S3, configurable retention periods. Every module documents its cost implications.

**Composable** — Modules output IDs, ARNs, and CIDRs so they plug into each other. The VPC module outputs subnet IDs that feed directly into EKS or RDS modules.

## Repository Structure

```
aws-terraform-modules/
├── modules/
│   ├── vpc/                    # VPC with public/private subnets, NAT, flow logs
│   ├── s3/                     # S3 with encryption, versioning, lifecycle rules
│   ├── eks/                    # EKS cluster (coming soon)
│   └── rds/                    # RDS/Aurora (coming soon)
├── examples/
│   └── full-stack/             # Complete example using all modules together
├── .github/
│   └── workflows/
│       ├── validate.yml        # CI: fmt, validate, tflint, checkov on every PR
│       └── docs.yml            # Auto-generate terraform-docs on merge
├── .tflint.hcl                 # TFLint configuration
├── CONTRIBUTING.md             # How to contribute
└── LICENSE                     # Apache 2.0
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for development setup, coding standards, and how to add new modules.

## License

Apache 2.0 — see [LICENSE](./LICENSE) for details.
