# Terraform Settings Block
terraform {
  required_version = ">= 1.8"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.35.0"
    }
  }
}

# Terraform Provider Block
provider "google" {
  project = "gcplearn9"
  region = "us-central1"
}