provider "google" {
  project = var.gcp_project_id
  region = var.region
  zone = var.zone
}

//resource "google_app_engine_application" "app" {
//  project = var.gcp_project_id
//  location_id = var.region
//  database_type = "CLOUD_DATASTORE_COMPATIBILITY"
//}
resource "google_project_service" "api" {
  for_each = toset(var.gcp_service_list)

  service = each.value
  disable_dependent_services = true
}
resource "google_cloud_run_service" "default" {
  name = "cloudrun-srv"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/roi-takeoff-user94/go-pets:v1"
        ports {
          container_port = var.port
        }
      }
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.default.location
  project = google_cloud_run_service.default.project
  service = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}





