# Resource: Cloud Router
resource "google_compute_router" "cloud_router" {
  name    = "${local.name}-${var.gcp_region1}-cloud-router"
  #network = google_compute_network.myvpc.id
  network = data.terraform_remote_state.project1.outputs.vpc_id
  region  = var.gcp_region1
}

# Resource: Cloud NAT
resource "google_compute_router_nat" "cloud_nat" {
  name   = "${local.name}-${var.gcp_region1}-cloud-nat"
  router = google_compute_router.cloud_router.name
  region = google_compute_router.cloud_router.region
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ALL"
  }
}
