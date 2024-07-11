## CONFIGS RELATED TO CLOUD SQL PRIVATE CONNECTION
# Resource: Reserve Private IP range for VPC Peering
resource "google_compute_global_address" "private_ip" {
  name          = "${local.name}-vpc-peer-privateip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.myvpc.id
}


# Resource: Private Service Connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.myvpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]
}
