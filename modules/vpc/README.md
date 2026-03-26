# VPC Module

Production-ready AWS VPC with public and private subnets, NAT Gateways, Internet Gateway, VPC Flow Logs, and a restricted default security group.

## Features

- Multi-AZ public and private subnets with auto-calculated CIDRs
- NAT Gateway (single or per-AZ) for private subnet internet access
- VPC Flow Logs to CloudWatch with configurable retention
- Default security group locked down (no ingress/egress)
- Kubernetes-ready subnet tags (`kubernetes.io/role/elb`)

## Usage

```hcl
module "vpc" {
  source = "github.com/shivajichaprana/aws-terraform-modules//modules/vpc"

  name               = "production"
  cidr               = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  enable_nat_gateway = true
  single_nat_gateway = false
  enable_flow_logs   = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## Cost Optimization

- Set `single_nat_gateway = true` for non-production environments to use one NAT Gateway instead of one per AZ (~$32/month savings per extra NAT)
- Set `enable_flow_logs = false` if CloudWatch costs are a concern in development

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
