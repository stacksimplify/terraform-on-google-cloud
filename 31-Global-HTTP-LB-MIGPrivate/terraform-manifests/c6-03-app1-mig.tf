# Resource: Managed Instance Group: Region1
resource "google_compute_region_instance_group_manager" "region1_myapp1" {
  depends_on = [ google_compute_router_nat.region1_cloud_nat ]
  region                     = var.gcp_region1
  name                       = "${local.name}-${var.gcp_region1}-myapp1-mig"
  base_instance_name         = "${local.name}-${var.gcp_region1}-myapp1"
  distribution_policy_zones  = data.google_compute_zones.region1.names
  # Instance Template
  version {
    instance_template = google_compute_region_instance_template.region1_myapp1.id
  }
  # Named Port
  named_port {
    name = "webserver"
    port = 80
  }
  # Autohealing
  auto_healing_policies {
    health_check      = google_compute_region_health_check.region1_myapp1.id
    initial_delay_sec = 300
  }
}

# Resource: Managed Instance Group: Region2
resource "google_compute_region_instance_group_manager" "region2_myapp1" {
  depends_on = [ google_compute_router_nat.region2_cloud_nat ]
  region                     = var.gcp_region2
  name                       = "${local.name}-${var.gcp_region2}-myapp1-mig"
  base_instance_name         = "${local.name}-${var.gcp_region2}-myapp1"
  distribution_policy_zones  = data.google_compute_zones.region2.names
  # Instance Template
  version {
    instance_template = google_compute_region_instance_template.region2_myapp1.id
  }
  # Named Port
  named_port {
    name = "webserver"
    port = 80
  }
  # Autohealing
  auto_healing_policies {
    health_check      = google_compute_region_health_check.region2_myapp1.id
    initial_delay_sec = 300
  }
}

