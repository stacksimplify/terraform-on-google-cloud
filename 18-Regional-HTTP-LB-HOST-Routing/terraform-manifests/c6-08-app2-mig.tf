# Resource: Managed Instance Group
resource "google_compute_region_instance_group_manager" "myapp2" {
  depends_on = [ google_compute_router_nat.cloud_nat ]
  name                       = "${local.name}-myapp2-mig"
  base_instance_name         = "${local.name}-myapp2"
  region                     = var.gcp_region1
  distribution_policy_zones  = data.google_compute_zones.available.names
  # Instance Template
  version {
    instance_template = google_compute_region_instance_template.myapp2.id
  }
  # Named Port
  named_port {
    name = "webserver"
    port = 80
  }
  # Autosclaing
  auto_healing_policies {
    health_check      = google_compute_region_health_check.myapp2.id
    initial_delay_sec = 300
  }
}
