# Docker Hub のイメージを Artifact Registry のリモートリポジトリ経由で使う
resource "google_artifact_registry_repository" "dockerhub" {
  location      = var.region
  repository_id = "${var.name_prefix}-dockerhub"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"

  remote_repository_config {
    description = "Docker Hub"
    docker_repository {
      public_repository = "DOCKER_HUB"
    }
  }

  depends_on = [google_project_service.apis]
}

# 受け取ったヘッダーと送信元 IP を JSON で返すアプリ（X-Forwarded-For の確認用）
resource "google_cloud_run_v2_service" "echo" {
  name                = "${var.name_prefix}-echo"
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  deletion_protection = false

  template {
    scaling {
      max_instance_count = 1
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.dockerhub.repository_id}/mendhak/http-https-echo:43"

      ports {
        container_port = 8080
      }
    }
  }

  depends_on = [google_project_service.apis]
}

# 検証用 VM のサービスアカウントだけに起動元を付与する。VM は ID トークンを付けてリクエストする。
resource "google_cloud_run_v2_service_iam_member" "invoker" {
  name     = google_cloud_run_v2_service.echo.name
  location = google_cloud_run_v2_service.echo.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.vm.email}"
}
