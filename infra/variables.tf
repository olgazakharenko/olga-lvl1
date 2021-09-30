variable "gcp_project_id" {
  description = "Project ID"
}
variable "region" {
  description = "Google region"
}
variable "zone" {
  description = "zone"
}
variable "port" {
  description = "port to run app"
}
variable "db_name" {
  description = "db name"
}
variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type = list(string)
  default = [
    "cloudapis.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "iam.googleapis.com"
  ]
}
