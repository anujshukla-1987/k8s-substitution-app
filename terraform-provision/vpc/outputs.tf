output "vpc_id" {
  description = "newly created vpc id"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "private subnet ids"
  value       = module.vpc.private_subnets
}
