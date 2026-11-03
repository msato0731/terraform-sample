# 接続側 VPC（アクセス元の VM を置く VPC）
resource "google_compute_network" "consumer" {
  name                    = "${var.name_prefix}-consumer-vpc"
  auto_create_subnetworks = false

  depends_on = [google_project_service.apis]
}

resource "google_compute_subnetwork" "consumer" {
  name          = "${var.name_prefix}-consumer-subnet"
  region        = var.region
  network       = google_compute_network.consumer.id
  ip_cidr_range = "10.10.0.0/24"
}

# 公開側 VPC（内部ALBと Cloud Run がある VPC）
resource "google_compute_network" "producer" {
  name                    = "${var.name_prefix}-producer-vpc"
  auto_create_subnetworks = false

  depends_on = [google_project_service.apis]
}

# 内部ALBの転送ルールが IP を取るサブネット
resource "google_compute_subnetwork" "producer" {
  name          = "${var.name_prefix}-producer-subnet"
  region        = var.region
  network       = google_compute_network.producer.id
  ip_cidr_range = "10.20.0.0/24"
}

# 内部ALB（Envoy プロキシ）用
resource "google_compute_subnetwork" "proxy_only" {
  name          = "${var.name_prefix}-proxy-only-subnet"
  region        = var.region
  network       = google_compute_network.producer.id
  ip_cidr_range = "10.20.1.0/24"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

# VPC Peering。2本のピアリングは同時に作成できないため、順番に作る。
resource "google_compute_network_peering" "consumer_to_producer" {
  name         = "${var.name_prefix}-consumer-to-producer"
  network      = google_compute_network.consumer.self_link
  peer_network = google_compute_network.producer.self_link
}

resource "google_compute_network_peering" "producer_to_consumer" {
  name         = "${var.name_prefix}-producer-to-consumer"
  network      = google_compute_network.producer.self_link
  peer_network = google_compute_network.consumer.self_link

  depends_on = [google_compute_network_peering.consumer_to_producer]
}

# IAP 経由の SSH（検証用 VM は外部 IP なし）
resource "google_compute_firewall" "consumer_iap_ssh" {
  name    = "${var.name_prefix}-consumer-allow-iap-ssh"
  network = google_compute_network.consumer.name

  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["peer-lab-vm"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
