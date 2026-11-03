resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "iap.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}
