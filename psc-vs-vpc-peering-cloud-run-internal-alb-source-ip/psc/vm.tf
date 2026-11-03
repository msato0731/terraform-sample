# アクセス元の VM（接続側 VPC）
resource "google_service_account" "vm" {
  account_id   = "${var.name_prefix}-vm"
  display_name = "PSC 検証用 VM"
}

resource "google_compute_instance" "client" {
  name         = "${var.name_prefix}-client"
  machine_type = "e2-micro"
  zone         = var.zone
  tags         = ["psc-lab-vm"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.consumer.id
  }

  service_account {
    email  = google_service_account.vm.email
    scopes = ["cloud-platform"]
  }


  depends_on = [google_compute_forwarding_rule.psc_endpoint]
}
