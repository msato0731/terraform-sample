terraform {
  required_version = ">= 1.9"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project               = var.project_id
  billing_project       = var.project_id
  user_project_override = true
}

# -------------------------------------------------------------------
# Workload Identity Federation
# -------------------------------------------------------------------
resource "google_iam_workload_identity_pool" "aws_pool" {
  workload_identity_pool_id = "aws-ec2-pool"
  display_name              = "AWS EC2 Pool"
  description               = "Workload Identity Pool for AWS EC2 access"
}

resource "google_iam_workload_identity_pool_provider" "aws_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.aws_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "aws-provider"
  display_name                       = "AWS Provider"

  aws {
    account_id = var.aws_account_id
  }

  attribute_mapping = {
    "google.subject"        = "assertion.arn"
    "attribute.aws_role"    = "assertion.arn.extract('assumed-role/{role}/')"
    "attribute.aws_account" = "assertion.account"
  }
}

resource "google_service_account" "vertex_ai_caller" {
  account_id   = "vertex-ai-caller"
  display_name = "Vertex AI Caller from EC2"
}

resource "google_project_iam_member" "vertex_ai_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.vertex_ai_caller.email}"
}

resource "google_service_account_iam_member" "wif_binding" {
  service_account_id = google_service_account.vertex_ai_caller.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.aws_pool.name}/attribute.aws_role/${var.ec2_iam_role_name}"
}

# -------------------------------------------------------------------
# Access Context Manager
# -------------------------------------------------------------------
resource "google_access_context_manager_access_policy" "policy" {
  parent = "organizations/${var.org_id}"
  title  = "${var.prefix}-vertex-ai-test-policy"
  scopes = ["projects/${var.project_number}"]
}

resource "google_access_context_manager_access_level" "allow_ec2" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.policy.name}/accessLevels/${var.prefix}_allow_ec2_ip"
  title  = "${var.prefix}_allow_ec2_ip"

  basic {
    conditions {
      ip_subnetworks = var.allowed_cidrs
    }
  }
}

# -------------------------------------------------------------------
# VPC Service Controls
# -------------------------------------------------------------------
resource "google_access_context_manager_service_perimeter" "vertex_ai" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.policy.name}/servicePerimeters/${var.prefix}_vertex_ai_perimeter"
  title  = "${var.prefix}_vertex_ai_perimeter"

  status {
    resources          = ["projects/${var.project_number}"]
    restricted_services = ["aiplatform.googleapis.com"]

    ingress_policies {
      ingress_from {
        sources {
          access_level = google_access_context_manager_access_level.allow_ec2.name
        }
        identity_type = "ANY_IDENTITY"
      }
      ingress_to {
        resources = ["*"]
        operations {
          service_name = "aiplatform.googleapis.com"
          method_selectors {
            method = "*"
          }
        }
      }
    }
  }
}
