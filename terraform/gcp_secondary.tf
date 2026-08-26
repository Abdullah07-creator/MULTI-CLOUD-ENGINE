# 1. Enable required GCP Service APIs
resource "google_project_service" "cloudrun_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# 2. GCP Cloud Run Service (Secondary Failover Workload)
resource "google_cloud_run_v2_service" "secondary_app" {
  name     = "multi-cloud-gcp-secondary"
  location = var.gcp_region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }

      env {
        name  = "CLOUD_PROVIDER"
        value = "GCP Secondary Cloud"
      }
      env {
        name  = "CLOUD_REGION"
        value = var.gcp_region
      }
    }
  }

  depends_on = [google_project_service.cloudrun_api]
}

# 3. IAM Policy to allow Public Unauthenticated HTTP Requests
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  location = google_cloud_run_v2_service.secondary_app.location
  name     = google_cloud_run_v2_service.secondary_app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# 4. Output Secondary GCP Cloud Run HTTPS Endpoint URL
output "gcp_secondary_url" {
  value       = google_cloud_run_v2_service.secondary_app.uri
  description = "HTTPS Endpoint URL of Secondary GCP Cloud Run Workload"
}
