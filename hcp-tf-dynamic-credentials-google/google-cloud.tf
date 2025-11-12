resource "google_iam_workload_identity_pool" "hcp_tf_pool" {
  workload_identity_pool_id = "hcp-tf-pool"
}

resource "google_iam_workload_identity_pool_provider" "hcp_tf_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.hcp_tf_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "hcp-tf-provider"
  attribute_mapping = {
    "google.subject"                        = "assertion.sub",
    "attribute.aud"                         = "assertion.aud",
    "attribute.terraform_run_phase"         = "assertion.terraform_run_phase",
    "attribute.terraform_project_id"        = "assertion.terraform_project_id",
    "attribute.terraform_project_name"      = "assertion.terraform_project_name",
    "attribute.terraform_workspace_id"      = "assertion.terraform_workspace_id",
    "attribute.terraform_workspace_name"    = "assertion.terraform_workspace_name",
    "attribute.terraform_organization_id"   = "assertion.terraform_organization_id",
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name",
    "attribute.terraform_run_id"            = "assertion.terraform_run_id",
    "attribute.terraform_full_workspace"    = "assertion.terraform_full_workspace",
  }
  oidc {
    issuer_uri = "https://${var.hcp_tf_hostname}"
  }
  attribute_condition = "assertion.sub.startsWith(\"organization:${var.hcp_tf_organization_name}:project:${var.hcp_tf_project_name}:workspace:\")"
}

resource "google_service_account" "hcp_tf_service_account" {
  account_id   = "hcp-tf-service-account"
  display_name = "Terraform Cloud Service Account"
}

resource "google_service_account_iam_member" "hcp_tf_service_account_member" {
  service_account_id = google_service_account.hcp_tf_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.hcp_tf_pool.name}/*"
}

resource "google_project_iam_member" "hcp_tf_project_member" {
  project = var.google_project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.hcp_tf_service_account.email}"
}
