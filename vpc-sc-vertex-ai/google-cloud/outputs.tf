output "workload_identity_pool_name" {
  description = "Workload Identity PoolのリソースID"
  value       = google_iam_workload_identity_pool.aws_pool.name
}

output "service_account_email" {
  description = "Vertex AI呼び出し用サービスアカウントのメールアドレス"
  value       = google_service_account.vertex_ai_caller.email
}

output "credential_config_command" {
  description = "EC2上で実行するcredential configファイル生成コマンド"
  value       = <<-EOT
    gcloud iam workload-identity-pools create-cred-config \
      ${google_iam_workload_identity_pool.aws_pool.name}/providers/${google_iam_workload_identity_pool_provider.aws_provider.workload_identity_pool_provider_id} \
      --service-account=${google_service_account.vertex_ai_caller.email} \
      --aws \
      --output-file=/tmp/gcp_credential_config.json
  EOT
}

output "access_policy_name" {
  description = "Access PolicyのリソースID"
  value       = google_access_context_manager_access_policy.policy.name
}
