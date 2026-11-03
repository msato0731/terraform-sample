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

resource "google_compute_region_target_http_proxy" "echo" {
  name    = "${var.name_prefix}-echo-http-proxy"
  region  = var.region
  url_map = google_compute_region_url_map.echo.id
}

# 内部ALBの転送ルール
resource "google_compute_forwarding_rule" "ilb" {
  name                  = "${var.name_prefix}-ilb"
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"
  network               = google_compute_network.producer.id
  subnetwork            = google_compute_subnetwork.producer.id
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.echo.id

  depends_on = [google_compute_subnetwork.proxy_only]
}
