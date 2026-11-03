output "ilb_ip" {
  description = "内部ALBの IP（公開側 VPC。VM の /etc/hosts に登録される。Peering 経由で届く）"
  value       = google_compute_forwarding_rule.ilb.ip_address
}

output "vm_ip" {
  description = "接続側 VPC の VM の IP（X-Forwarded-For に出るか確認する）"
  value       = google_compute_instance.client.network_interface[0].network_ip
}

output "cloud_run_url" {
  description = "Cloud Run の既定 URL（受信設定が内部のため、インターネットからは届かない）"
  value       = google_cloud_run_v2_service.echo.uri
}

output "ssh_command" {
  value = "gcloud compute ssh ${google_compute_instance.client.name} --zone ${var.zone} --tunnel-through-iap --project ${var.project_id}"
}

output "curl_command_on_vm" {
  description = "VM 上で実行する確認コマンド（ID トークンを付けて呼び出す）"
  value       = <<-EOT
    TOKEN=$(curl -s -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity?audience=${google_cloud_run_v2_service.echo.uri}")
    curl -sS --cacert /opt/lab/server.pem -H "Authorization: Bearer $TOKEN" https://${var.domain_name}/
  EOT
}
