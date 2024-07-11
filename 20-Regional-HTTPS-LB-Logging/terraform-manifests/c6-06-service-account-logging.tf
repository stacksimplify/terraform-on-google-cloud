# Service Account
resource "google_service_account" "myapp1" {
  account_id   = "${local.name}-myapp1-mig-sa"
  display_name = "Service Account"
}

# Log Writer Permission to Service Account
resource "google_project_iam_member" "logging_role" {
  project = var.gcp_project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.myapp1.email}"
}

# Metric Writer Permission to Service Account
resource "google_project_iam_member" "monitoring_role" {
  project = var.gcp_project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.myapp1.email}"
}