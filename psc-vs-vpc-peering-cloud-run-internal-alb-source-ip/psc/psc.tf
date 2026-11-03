# 公開側: サービスアタッチメント
resource "google_compute_service_attachment" "producer" {
  name        = "${var.name_prefix}-attachment"
  region      = var.region
  description = "内部ALBを PSC で公開する"

  enable_proxy_protocol = false
  connection_preference = "ACCEPT_MANUAL"

  # 承諾リストの変更を、承諾済み・拒否済みの既存エンドポイントにも反映する（承諾リストの検証用）
  reconcile_connections = true
  nat_subnets           = [google_compute_subnetwork.psc_nat.id]
  target_service        = google_compute_forwarding_rule.ilb.id

  consumer_accept_lists {
    project_id_or_num = var.project_id
    connection_limit  = 10
  }
}

# 接続側: PSC エンドポイント（接続側 VPC のサブネットから内部 IP を取る）
resource "google_compute_address" "psc_endpoint" {
  name         = "${var.name_prefix}-endpoint-ip"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.consumer.id
}

resource "google_compute_forwarding_rule" "psc_endpoint" {
  name                  = "${var.name_prefix}-endpoint"
  region                = var.region
  network               = google_compute_network.consumer.id
  ip_address            = google_compute_address.psc_endpoint.id
  target                = google_compute_service_attachment.producer.id
  load_balancing_scheme = ""
}
