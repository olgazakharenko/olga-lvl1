provider "google" {
  project = var.gcp_project_id
  region = var.region
  zone = var.zone
}
locals {
  cloud_run_url = google_cloud_run_service.pets-api.status[0].url
}

resource "google_project_service" "pets-api" {
  for_each = toset(var.gcp_service_list)

  service = each.value
  disable_dependent_services = true
}

resource "google_cloud_run_service" "pets-api" {
  name = "pets-api"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/roi-takeoff-user94/go-pets:v1"
        env {
          name = "GOOGLE_CLOUD_PROJECT"
          value = var.gcp_project_id
        }
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

resource "google_service_account" "pets-api-sa" {
  account_id   = "pets-api-sa"
  display_name = "Service account for pets API"
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.pets-api.location
  project = google_cloud_run_service.pets-api.project
  service = google_cloud_run_service.pets-api.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_endpoints_service" "pets-api" {
  service_name = "${replace(local.cloud_run_url, "https://", "")}"
  project = var.gcp_project_id
  openapi_config = <<EOF
    swagger: '2.0'
    info:
      title: Cloud Endpoints + Cloud Run
      description: Sample API on Cloud Endpoints with a Cloud Run backend
      version: 1.0.0
    host: "${replace(local.cloud_run_url, "https://", "")}"
    schemes:
      - https
    produces:
      - application/json
    x-google-backend:
      address: "${local.cloud_run_url}"
      protocol: h2
    paths:
          /pets:
            get:
              summary: Returns a list of pets.
              operationId: getListOfEvents
              produces:
                - application/json
              responses:
                '200':
                  description: A JSON array of the pets
                  schema:
                    type: array
            post:
              summary: Create a pet.
              operationId: createPet
              consumes:
                - application/json
              parameters:
                - in: body
                  name: pets
                  description: The pets to create
                  schema:
                    type: string
              responses:
                '200':
                  description: OK
          /pets/{id}:
            get:
              summary: Get a pets by ID
              operationId: getPetById
              parameters:
              - in: path
                name: id
                type: string
                required: true
                description: String ID of the pet to get
              produces:
              - application/json
              responses:
                '200':
                  description: A JSON array of pets
                  schema:
                    type: array
  EOF

  depends_on = [
    google_cloud_run_service.pets-api]
}




