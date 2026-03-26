# S3 Module

Secure-by-default AWS S3 bucket with encryption, versioning, public access blocking, lifecycle rules, and access logging.

## Features

- SSE-S3 (AES256) or SSE-KMS encryption enabled by default
- Public access blocked by default
- Versioning with noncurrent version expiration
- Lifecycle rules for cost optimization (STANDARD → IA → GLACIER)
- Automatic cleanup of incomplete multipart uploads
- CORS configuration support
- Optional access logging

## Usage

```hcl
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

### With KMS encryption

```hcl
module "encrypted_bucket" {
  source = "github.com/shivajichaprana/aws-terraform-modules//modules/s3"

  bucket_name     = "myapp-sensitive-data"
  kms_key_arn     = aws_kms_key.my_key.arn
  enable_versioning = true

  tags = {
    Environment = "production"
  }
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
