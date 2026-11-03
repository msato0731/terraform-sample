# 接続側 VPC（アクセス元の VM を置く VPC）
resource "google_compute_network" "lan" {
  name                    = "${var.name_prefix}-lan-vpc"
  auto_create_subnetworks = false

  depends_on = [google_project_service.apis]
}

resource "google_compute_subnetwork" "lan" {
  name          = "${var.name_prefix}-lan-subnet"
  region        = var.region
  network       = google_compute_network.lan.id
  ip_cidr_range = "10.10.0.0/24"
}

# 公開側 VPC（内部ALBと Cloud Run がある VPC）
resource "google_compute_network" "app" {
  name                    = "${var.name_prefix}-app-vpc"
  auto_create_subnetworks = false

  depends_on = [google_project_service.apis]
}

# 内部ALBの転送ルールが IP を取るサブネット
resource "google_compute_subnetwork" "app" {
  name          = "${var.name_prefix}-app-subnet"
  region        = var.region
  network       = google_compute_network.app.id
  ip_cidr_range = "10.20.0.0/24"
}

# 内部ALB（Envoy プロキシ）用
resource "google_compute_subnetwork" "proxy_only" {
  name          = "${var.name_prefix}-proxy-only-subnet"
  region        = var.region
  network       = google_compute_network.app.id
  ip_cidr_range = "10.20.1.0/24"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

# VPC Peering。2本のピアリングは同時に作成できないため、順番に作る。
resource "google_compute_network_peering" "lan_to_app" {
  name         = "${var.name_prefix}-lan-to-app"
  network      = google_compute_network.lan.self_link
  peer_network = google_compute_network.app.self_link
}

resource "google_compute_network_peering" "app_to_lan" {
  name         = "${var.name_prefix}-app-to-lan"
  network      = google_compute_network.app.self_link
  peer_network = google_compute_network.lan.self_link

  depends_on = [google_compute_network_peering.lan_to_app]
}

# IAP 経由の SSH（検証用 VM は外部 IP なし）
resource "google_compute_firewall" "lan_iap_ssh" {
  name    = "${var.name_prefix}-lan-allow-iap-ssh"
  network = google_compute_network.lan.name

  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["peer-lab-vm"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
