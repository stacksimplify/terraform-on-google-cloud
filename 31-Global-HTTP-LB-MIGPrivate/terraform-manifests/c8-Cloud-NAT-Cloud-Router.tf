# Resource: Cloud Router: Region1
resource "google_compute_router" "region1_cloud_router" {
  name    = "${local.name}-${var.gcp_region1}-cloud-router"
  network = google_compute_network.myvpc.id
  region  = var.gcp_region1
}

# Resource: Cloud NAT: Region1
resource "google_compute_router_nat" "region1_cloud_nat" {
  name   = "${local.name}-${var.gcp_region1}-cloud-nat"
  router = google_compute_router.region1_cloud_router.name
  region = google_compute_router.region1_cloud_router.region
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ALL"
  }
}

# Resource: Cloud Router: Region2
resource "google_compute_router" "region2_cloud_router" {
  name    = "${local.name}-${var.gcp_region2}-cloud-router"
  network = google_compute_network.myvpc.id
  region  = var.gcp_region2
}

# Resource: Cloud NAT: Region2
resource "google_compute_router_nat" "region2_cloud_nat" {
  name   = "${local.name}-${var.gcp_region2}-cloud-nat"
  router = google_compute_router.region2_cloud_router.name
  region = google_compute_router.region2_cloud_router.region
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ALL"
  }
}



