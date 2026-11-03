# アクセス元の VM（接続側 VPC）。名前解決は /etc/hosts で行う
resource "google_service_account" "vm" {
  account_id   = "${var.name_prefix}-vm"
  display_name = "Peering 検証用 VM"
}

resource "google_compute_instance" "client" {
  name         = "${var.name_prefix}-client"
  machine_type = "e2-micro"
  zone         = var.zone
  tags         = ["peer-lab-vm"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.lan.id
  }

  service_account {
    email  = google_service_account.vm.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = templatefile("${path.module}/startup.sh.tftpl", {
    ilb_ip      = google_compute_forwarding_rule.ilb.ip_address
    domain_name = var.domain_name
  })
}
