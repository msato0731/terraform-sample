# 検証用の自己署名証明書（本番では独自ドメインの正規の証明書を使う）
resource "tls_private_key" "app" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "app" {
  private_key_pem = tls_private_key.app.private_key_pem

  subject {
    common_name = var.domain_name
  }

  dns_names             = [var.domain_name]
  validity_period_hours = 168
  allowed_uses          = ["key_encipherment", "digital_signature", "server_auth"]
}

resource "google_compute_region_ssl_certificate" "app" {
  name_prefix = "${var.name_prefix}-"
  region      = var.region
  private_key = tls_private_key.app.private_key_pem
  certificate = tls_self_signed_cert.app.cert_pem

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_network_endpoint_group" "echo" {
  name                  = "${var.name_prefix}-echo-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = google_cloud_run_v2_service.echo.name
  }
}

resource "google_compute_region_backend_service" "echo" {
  name                  = "${var.name_prefix}-echo-backend"
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol              = "HTTP"

  backend {
    group = google_compute_region_network_endpoint_group.echo.id
  }
}

resource "google_compute_region_url_map" "echo" {
  name            = "${var.name_prefix}-echo-urlmap"
  region          = var.region
  default_service = google_compute_region_backend_service.echo.id
}

resource "google_compute_region_target_https_proxy" "echo" {
  name             = "${var.name_prefix}-echo-https-proxy"
  region           = var.region
  url_map          = google_compute_region_url_map.echo.id
  ssl_certificates = [google_compute_region_ssl_certificate.app.id]
}

# 内部ALBの転送ルール
resource "google_compute_forwarding_rule" "ilb" {
  name                  = "${var.name_prefix}-ilb"
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"
  network               = google_compute_network.app.id
  subnetwork            = google_compute_subnetwork.app.id
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_region_target_https_proxy.echo.id

  depends_on = [google_compute_subnetwork.proxy_only]
}
