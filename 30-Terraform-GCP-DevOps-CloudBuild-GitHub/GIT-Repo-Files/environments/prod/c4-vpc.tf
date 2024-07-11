# Resource: VPC
resource "google_compute_network" "myvpc" {
  name = "${local.name}-vpc"
  auto_create_subnetworks = false   
}

# Resource: Subnet
resource "google_compute_subnetwork" "mysubnet" {
  name = "${local.name}-${var.gcp_region1}-subnet"
  region = var.gcp_region1
  ip_cidr_range = "10.132.0.0/20"
  network = google_compute_network.myvpc.id 
}
