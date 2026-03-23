output "nat_gateway_ip" {
  description = "NAT GatewayのEIP（GCP側のIP許可リストに設定する値）"
  value       = aws_eip.nat.public_ip
}

output "ec2_instance_id" {
  description = "EC2インスタンスID（SSM Session Manager接続に使用）"
  value       = aws_instance.test.id
}

output "ec2_iam_role_arn" {
  description = "EC2のIAMロールARN（GCP Workload Identity Provider設定に使用）"
  value       = aws_iam_role.ec2.arn
}
