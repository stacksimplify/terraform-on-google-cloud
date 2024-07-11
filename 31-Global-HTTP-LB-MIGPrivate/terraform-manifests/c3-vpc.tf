# Resource: VPC
resource "google_compute_network" "myvpc" {
  name = "${local.name}-vpc"
  auto_create_subnetworks = false   
}

# Resource: Subnet (Region1)
resource "google_compute_subnetwork" "region1" {
  name = "${var.gcp_region1}-subnet"
  region = var.gcp_region1
  ip_cidr_range = "10.128.0.0/20"
  network = google_compute_network.myvpc.id 
}

# Resource: Subnet (Region2)
resource "google_compute_subnetwork" "region2" {
  name = "${var.gcp_region2}-subnet"
  region = var.gcp_region2
  ip_cidr_range = "10.132.0.0/20"
  network = google_compute_network.myvpc.id 
  private_ip_google_access = true 
}
