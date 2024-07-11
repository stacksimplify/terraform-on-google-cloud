module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 9.1"
    project_id   = var.gcp_project
    network_name = "${local.name}-vpc"
    routing_mode = "GLOBAL"
    subnets = [
        {
            subnet_name           = "${local.name}-${var.gcp_region1}-subnet"
            subnet_ip             = "10.128.0.0/20"
            subnet_region         = var.gcp_region1
        }
    ]
}



/*
# Resource: VPC
resource "google_compute_network" "myvpc" {
  name = "${local.name}-vpc"
  auto_create_subnetworks = false   
}

# Resource: Subnet
resource "google_compute_subnetwork" "mysubnet" {
  name = "${local.name}-${var.gcp_region1}-subnet"
  region = var.gcp_region1
  ip_cidr_range = "10.128.0.0/20"
  network = google_compute_network.myvpc.id 
}
*/