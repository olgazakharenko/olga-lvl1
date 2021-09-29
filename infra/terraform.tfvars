# GCP Settings
gcp_project_id = "roi-takeoff-user94"
region = "us-east4"
zone = "us-east4-a"
port = "8080"
db_name = "go-pets-db"
gcp_service_list = {
  type = list(string)
  default = [
    "cloudbuild.googleapis.com"
  ]
}