variable "hcp_tf_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "The hostname of the HCP Terraform or TFE instance you'd like to use with GCP"
}

variable "hcp_tf_organization_name" {
  type        = string
  description = "The name of your HCP Terraform organization"
}

variable "hcp_tf_project_name" {
  type        = string
  default     = "Default Project"
  description = "The project under which a workspace will be created"
}

variable "hcp_tf_variables_set_name" {
  type        = string
  default     = "google-cloud-auth"
  description = "The name of the Variable Set to create for Google Cloud authentication"
}

variable "google_project_id" {
  type        = string
  description = "The ID for your Google Cloud project"
}
