output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPCのCIDRブロック"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "パブリックサブネットのID一覧"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "プライベートサブネットのID一覧"
  value       = module.vpc.private_subnets
}

output "nat_public_ips" {
  description = "NAT GatewayのパブリックIP一覧"
  value       = module.vpc.nat_public_ips
}
