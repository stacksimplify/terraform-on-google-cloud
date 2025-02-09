# Terraform Settings Block
terraform {
  required_version = ">= 1.9"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.36.0"
    }
  }
  backend "gcs" {
    bucket = "terraform-on-gcp-gke-boris"
    prefix = "cloudsql/privatedb"
  }
}

# Terraform Provider Block
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region1
}