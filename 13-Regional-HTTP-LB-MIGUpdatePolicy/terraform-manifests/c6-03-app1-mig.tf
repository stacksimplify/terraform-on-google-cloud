# Resource: Managed Instance Group
resource "google_compute_region_instance_group_manager" "myapp1" {
  depends_on = [ google_compute_router_nat.cloud_nat ]
  name                       = "${local.name}-myapp1-mig"
  base_instance_name         = "${local.name}-myapp1"
  region                     = var.gcp_region1
  distribution_policy_zones  = data.google_compute_zones.available.names
  # Instance Template
  version {
    # V1 Version
    instance_template = google_compute_region_instance_template.myapp1.id
    # V2 Version
    #instance_template = google_compute_region_instance_template.myapp1_v2.id
  }
  # Named Port
  named_port {
    name = "webserver"
    port = 80
  }
  # Autosclaing
  auto_healing_policies {
    health_check      = google_compute_region_health_check.myapp1.id
    initial_delay_sec = 300
  }
  # Update Policy
  update_policy {
    type                           = "PROACTIVE"
    instance_redistribution_type   = "PROACTIVE"
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed                = length(data.google_compute_zones.available.names)
    max_unavailable_fixed          = length(data.google_compute_zones.available.names)
    replacement_method             = "SUBSTITUTE"
    # min_ready_sec                  = 50 #   (BETA Parameter)
  }  
}
