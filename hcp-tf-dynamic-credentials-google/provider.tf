provider "google" {
  project = var.google_project_id
  region  = "global"
}

provider "tfe" {
  hostname = var.hcp_tf_hostname
}
