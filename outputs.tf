output "alb_url" {
  description = "Public URL for the demo application."
  value       = "http://${module.web.alb_dns_name}"
}

output "application_subnet_ids" {
  description = "Private subnet IDs used by the EC2 Auto Scaling group."
  value       = module.network.application_subnet_ids
}

output "database_address" {
  description = "Private RDS endpoint address."
  value       = module.database.address
}

output "database_subnet_ids" {
  description = "Private subnet IDs used by RDS."
  value       = module.network.database_subnet_ids
}

output "vpc_id" {
  description = "VPC ID for the stack."
  value       = module.network.vpc_id
}
