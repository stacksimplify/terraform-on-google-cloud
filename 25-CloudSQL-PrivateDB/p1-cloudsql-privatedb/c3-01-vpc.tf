# Resource: VPC
resource "google_compute_network" "myvpc" {
  name = "${local.name}-vpc"
  auto_create_subnetworks = false   
}

# Resource: Subnet
resource "google_compute_subnetwork" "mysubnet" {
  name = "${var.gcp_region1}-subnet"
  region = var.gcp_region1
  ip_cidr_range = "10.128.0.0/24"
  network = google_compute_network.myvpc.id 
}

# Resource: Regional Proxy-Only Subnet (Required for Regional Application Load Balancer)
resource "google_compute_subnetwork" "regional_proxy_subnet" {
  name             = "${var.gcp_region1}-regional-proxy-subnet"
  region           = var.gcp_region1
  ip_cidr_range    = "10.0.0.0/24"
  purpose          = "REGIONAL_MANAGED_PROXY"
  network          = google_compute_network.myvpc.id
  role             = "ACTIVE"
}