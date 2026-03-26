output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "state_bucket_arn" {
  description = "ARN of the Terraform state bucket"
  value       = module.terraform_state_bucket.bucket_arn
}

output "assets_bucket_arn" {
  description = "ARN of the assets bucket"
  value       = module.assets_bucket.bucket_arn
}
