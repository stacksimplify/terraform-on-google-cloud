# Terraform Provider Configuration: google
provider "google" {
  project = "gcplearn9"
  region = "us-central1"
}

# Resource: VPC
resource "google_compute_network" "myvpc" {
  name = "vpc1"
  auto_create_subnetworks = false   
}

# Resource: Subnet
resource "google_compute_subnetwork" "mysubnet" {
  name          = "subnet1"
  region        = "us-central1"
  ip_cidr_range = "10.128.0.0/20"
  network       = google_compute_network.myvpc.id  // GET VPC ID
}

