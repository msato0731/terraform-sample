resource "tfe_project" "this" {
  name         = var.hcp_tf_project_name
  organization = var.hcp_tf_organization_name
}

resource "tfe_variable_set" "this" {
  name         = var.hcp_tf_variables_set_name
  organization = var.hcp_tf_organization_name
}

resource "tfe_project_variable_set" "this" {
  variable_set_id = tfe_variable_set.this.id
  project_id      = tfe_project.this.id
}


resource "tfe_variable" "enable_gcp_provider_auth" {
  variable_set_id = tfe_variable_set.this.id

  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for GCP."
}

resource "tfe_variable" "hcp_tf_gcp_workload_provider_name" {
  variable_set_id = tfe_variable_set.this.id

  key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value    = google_iam_workload_identity_pool_provider.hcp_tf_provider.name
  category = "env"

  description = "The workload provider name to authenticate against."
}

resource "tfe_variable" "hcp_tf_gcp_service_account_email" {
  variable_set_id = tfe_variable_set.this.id

  key      = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value    = google_service_account.hcp_tf_service_account.email
  category = "env"

  description = "The Google Cloud service account email runs will use to authenticate."
}
